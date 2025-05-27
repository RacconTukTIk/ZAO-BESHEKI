# frozen_string_literal: true

require_relative "nba_players_metrics/version"
require 'csv'
require 'date'

module NbaPlayersMetrics
  class Error < StandardError; end
  
  # Основной класс для работы с данными NBA
  class Stats

  end

  # Фабричный метод для создания экземпляра Stats
  def self.load_data(file_path)
    Stats.new(file_path)
  end
end
