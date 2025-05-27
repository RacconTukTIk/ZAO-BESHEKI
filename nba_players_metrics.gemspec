# frozen_string_literal: true

require_relative "lib/nba_players_metrics/version"

Gem::Specification.new do |spec|
  spec.name = "nba_players_metrics"
  spec.version = NbaPlayersMetrics::VERSION
  spec.authors = ["muzeel", "RacconTukTik", "majorcom", "dsinelnikov857"]
  spec.email = ["vasilets.4@mail.ru"]

  spec.summary = "Метрики игроков NBA и статистика матчей"
  spec.description = "Гем для анализа эффективности спортсменов/команд на основе статистических данных."
  spec.homepage = "https://github.com/RacconTukTIk/ZAO-BESHEKI"
  spec.required_ruby_version = ">= 3.1.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RacconTukTIk/ZAO-BESHEKI"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "sinatra", "~> 3.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end