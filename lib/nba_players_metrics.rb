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
  end

  # Фабричный метод для создания экземпляра Stats
  def self.load_data(file_path)
    Stats.new(file_path)
  end
end
