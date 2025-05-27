# frozen_string_literal: true

require_relative "nba_players_metrics/version"
require 'csv'
require 'date'

module NbaPlayersMetrics
  class Error < StandardError; end
  
  # Основной класс для работы с данными NBA
  class Stats
    def initialize(file_path)
      @shots_data = parse_csv(file_path)
      @players_index = create_players_index
      @teams_index = create_teams_index
      @defence_index = create_defence_index
    end

    # Поиск игрока по имени
    def find_player(player_name)
      shots = @players_index[player_name] || []
      Player.new(player_name, shots, self)
    end

    # Поиск команды по коду
    def find_team(team_code)
      games = @teams_index[team_code] || []
      Team.new(team_code, games)
    end

    # Получение всех защитных ситуаций для игрока
    def defences_for(defender_name)
      @defence_index.fetch(defender_name, [])
    end

    # Класс для представления игрока
    class Player
      attr_reader :name

      def initialize(name, shots, parent_stats)
        @name = name
        @shots = shots
        @parent_stats = parent_stats
      end

      # Количество всех бросков
      def count_shots(game_id: nil)
        filter_shots(game_id).size
      end

      # Количество успешных бросков
      def count_success_shots(game_id: nil)
        filter_shots(game_id).count { |s| s[:shot_result] }
      end

      # Процент попаданий
      def shooting_percentage(game_id: nil)
        shots = filter_shots(game_id)
        return 0.0 if shots.empty?
        (count_success_shots(game_id).to_f / shots.size * 100).round(1)
      end

      # Средняя дистанция атаки
      def attack_distance(game_id: nil, period: nil, shot_result: nil)
        shots = filter_shots(game_id, period, shot_result)
        return 0.0 if shots.empty?
        (shots.sum { |s| s[:shot_dist] } / shots.size.to_f).round(1)
      end

      # Статистика дистанций атаки
      def attack_distance_stats(options = {})
        shots = filter_shots(options)
        return empty_distance_stats if shots.empty?

        distances = shots.map { |s| s[:shot_dist] }
        {
          average: (distances.sum / distances.size.to_f).round(1),
          median: calculate_median(distances),
          min: distances.min,
          max: distances.max,
          distribution: distance_distribution(distances)
        }
      end

      # Количество дриблингов
      def count_dribbles(game_id: nil)
        shots = filter_shots(game_id)
        shots.sum { |s| s[:dribbles].to_i }
      end

      # Статистика дриблинга
      def dribble_stats(game_id: nil)
        shots = filter_shots(game_id)
        with_dribbles = shots.select { |s| s[:dribbles].to_i > 0 }

        {
          total_dribbles: count_dribbles(game_id),
          dribble_instances: with_dribbles.size,
          average_per_shot: shots.empty? ? 0 : (count_dribbles(game_id).to_f / shots.size).round(1),
          success_rate: calculate_dribble_success_rate(with_dribbles)
        }
      end

      # Количество защитных ситуаций
      def count_all_defences
        @parent_stats.defences_for(@name).size
      end

      # Количество успешных защит
      def count_success_defences
        @parent_stats.defences_for(@name).count { |s| !s[:shot_result] }
      end

      # Эффективность защиты
      def defender_efficiency(distance_from_basket: nil, attacker: nil)
        defences = filter_defences(distance_from_basket, attacker)
        return 0.0 if defences.empty?
        (defences.count { |s| !s[:shot_result] }.to_f / defences.size).round(3)
      end

      private

      def filter_shots(game_id = nil, period = nil, shot_result = nil)
        @shots.select do |s|
          (game_id.nil? || s[:game_id] == game_id) &&
          (period.nil? || s[:period] == period) &&
          (shot_result.nil? || s[:shot_result] == shot_result)
        end
      end

      def filter_defences(distance, attacker)
        defences = @parent_stats.defences_for(@name)
        defences.select do |s|
          (distance.nil? || s[:shot_dist] <= distance) &&
          (attacker.nil? || s[:player_name] == attacker)
        end
      end

      def calculate_median(distances)
        sorted = distances.sort
        len = sorted.length
        (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
      end

      def distance_distribution(distances)
        {
          '0-5 ft' => distances.count { |d| d <= 5 },
          '5-15 ft' => distances.count { |d| d > 5 && d <= 15 },
          '15-22 ft' => distances.count { |d| d > 15 && d <= 22 },
          '22+ ft' => distances.count { |d| d > 22 }
        }
      end

      def calculate_dribble_success_rate(shots)
        return 0.0 if shots.empty?
        (shots.count { |s| s[:shot_result] }.to_f / shots.size).round(3)
      end

      def empty_distance_stats
        {
          average: 0.0,
          median: 0.0,
          min: 0.0,
          max: 0.0,
          distribution: {}
        }
      end
    end

    # Класс для представления команды
    class Team
      def initialize(name, games_data)
        @name = name
        @games_data = games_data
      end

      # Среднее количество очков за матч
      def count_average_score(game_id: nil)
        games = game_id ? [find_game(game_id)] : @games_data
        return 0 if games.empty?
        (games.sum { |g| g[:team_score] } / games.size.to_f).round(1)
      end

      # Результаты игр
      def game_results
        @games_data.map do |game|
          {
            game_id: game[:game_id],
            score: game[:team_score],
            opponent: game[:opponent],
            result: game[:team_score] > game[:opponent_score] ? 'W' : 'L',
            date: parse_game_date(game[:matchup])
          }
        end
      end

      private

      def find_game(game_id)
        @games_data.find { |g| g[:game_id] == game_id } || {}
      end

      def parse_game_date(matchup)
        date_str = matchup.split(' - ').first
        Date.parse(date_str)
      end
    end

    private

    # Парсинг CSV файла
    def parse_csv(file_path)
      unless File.exist?(file_path)
        raise Error, "File not found: #{file_path}"
      end

      CSV.read(file_path, headers: true, header_converters: :symbol).map do |row|
        {
          game_id: row[:game_id],
          matchup: row[:matchup],
          location: row[:location],
          shot_number: row[:shot_number].to_i,
          period: row[:period].to_i,
          game_clock: row[:game_clock],
          shot_clock: row[:shot_clock].empty? ? nil : row[:shot_clock].to_f,
          dribbles: row[:dribbles].to_i,
          shot_dist: row[:shot_dist].to_f,
          pts_type: row[:pts_type].to_i,
          shot_result: row[:shot_result] == 'made',
          closest_defender: row[:closest_defender],
          defender_dist: row[:close_def_dist].to_f,
          pts: row[:pts].to_i,
          player_name: row[:player_name],
          player_id: row[:player_id].to_i
        }
      end
    end

    # Создание индекса игроков
    def create_players_index
      @shots_data.group_by { |shot| shot[:player_name] }
    end

    # Создание индекса команд
    def create_teams_index
      @shots_data.each_with_object({}) do |shot, result|
        team_code = parse_team_code(shot[:matchup])
        game_id = shot[:game_id]

        result[team_code] ||= {}
        result[team_code][game_id] ||= {
          game_id: game_id,
          matchup: shot[:matchup],
          team_score: 0,
          opponent_score: 0,
          opponent: parse_opponent_code(shot[:matchup])
        }

        result[team_code][game_id][:team_score] += shot[:pts] if shot[:shot_result]
      end.transform_values { |games| games.values }
    end

    # Создание индекса защитных ситуаций
    def create_defence_index
      @shots_data.group_by { |shot| shot[:closest_defender] }
    end

    # Парсинг кода команды из строки матча
    def parse_team_code(matchup)
      matchup.split(' - ').last.split(/ @ | vs /).first
    end

    # Парсинг кода соперника из строки матча
    def parse_opponent_code(matchup)
      matchup.split(' - ').last.split(/ @ | vs /).last
    end
  end
  end

  # Фабричный метод для создания экземпляра Stats
  def self.load_data(file_path)
    Stats.new(file_path)
  end
end
