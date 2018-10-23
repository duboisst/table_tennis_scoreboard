require 'json'

module Score
  class MyMatch
    PROPERTIES = [:id, :number_of_games, :players, :filename, :creation_datetime].freeze

    attr_accessor *PROPERTIES

    def initialize(options = {})
      raise ArgumentError, 'Please specify the :user_data_path for new item or the :filename to load existing' unless options[:user_data_path]

      if options[:filename]
        load_from_file(options[:filename])
      else
        # New item. When saved, it will be placed under the :user_data_path value
        @id = options[:id]
        @creation_datetime = Time.now.to_s
        @filename = "#{options[:user_data_path]}/#{id}.json"

        options[:players] ||= [{name: "", games: [], serve: true}, {name: "", games: [], serve: false}]

        @players = options[:players] 
        @number_of_games = options[:number_of_games] || 5
      end

      limits!
    end

    # Loads an item from a file
    def load_from_file(filename)
      puts "LOAD MATCH #{filename}"
      properties = JSON.parse(File.read(filename),{:symbolize_names => true})
      puts "LOAD - Properties: #{properties.inspect}"

      # Assign the properties
      PROPERTIES.each do |property|
        self.send "#{property}=", properties[property]
      end
      puts "LOAD - Players: #{players.inspect}"
    rescue => e
      raise ArgumentError, "Failed to load existing item: #{e.message}"
    end

    # Saves an item to its `filename` location
    def save!
      File.open(@filename, 'w') do |file|
        file.write self.to_json
      end
      puts "Match #{id} saved in #{@filename}"
    end

    # Produces a json string for the item
    def to_json
      result = {}
      PROPERTIES.each do |prop|
        result[prop] = self.send prop
      end

      result.to_json
    end

    def player_games player_indice
      games = 0
      player = players[player_indice]
      if player_indice == 0
        other_player = players[1]
      else
        other_player = players[0]
      end
      for g in 0..number_of_games-1
        games+=1 if player[:games][g] && other_player[:games][g] && player[:games][g]>other_player[:games][g] && player[:games][g]>=11 && player[:games][g]-other_player[:games][g]>=2
      end
      games
    end

    def player_has_serve? player_indice
      players[player_indice][:serve]
    end

    def players=(input)
      @players = input
      limits!
    end

    private

    def limits!
      for p in 0..1
        for g in 0..number_of_games-1
          score = players[p][:games][g]
          if p == 0
              opponent_player = 1
          else
              opponent_player = 0
          end
          opponent_score = players[opponent_player][:games][g]
          if score && opponent_score
            if score > 11 && opponent_score < 10
              players[p][:games][g] = 11
            elsif score > 11 && score > opponent_score && (score - opponent_score) >= 2 
              players[p][:games][g] = opponent_score+2
            end
          end
        end
      end
    end
  end
end