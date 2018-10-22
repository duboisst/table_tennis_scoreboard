module Score
    class MyWindow < Gtk::ApplicationWindow
        # Register the class in the GLib world
        type_register

        class << self
            def init
            end
        end

        def initialize(application)
            super application: application
            @number_of_games = 5
            init_ui
            @scoreboard_window = ScoreWindow.new(@number_of_games)
            new_match
            @scoreboard_window.present
        end

        def init_ui
            set_title 'Table tennis scoreboard'
            set_resizable false

            vbox = Gtk::Box.new :vertical, 2
        
            mb = Gtk::MenuBar.new
            filemenu = Gtk::Menu.new
            file = Gtk::MenuItem.new label: "File"
            file.set_submenu filemenu
            filemenu.append(new_menu = Gtk::MenuItem.new(label: "New"))
            filemenu.append(load_menu = Gtk::MenuItem.new(label: "Load"))
            filemenu.append(save_menu = Gtk::MenuItem.new(label: "Save"))
            new_menu.signal_connect 'activate' do
                new_match
            end
            load_menu.signal_connect 'activate' do
                match = Score::MyMatch.new(user_data_path: application.user_data_path, filename: '.gtk-score/match1.json')
                load match
            end
            save_menu.signal_connect 'activate' do
                set_match.save!
            end

            mb.append file
    
            vbox.pack_start mb, :expand => false, :fill => false, :padding => 0
            
            nbgames = Gtk::SpinButton.new(1,7,1)
            nbgames.value = @number_of_games
            nbgames.signal_connect 'value-changed' do |sb|
                @number_of_games = sb.value
                set_match
            end
            # vbox.pack_start nbgames, :expand => false, :fill => false, :padding => 0

            grid = Gtk::Grid.new
            grid.margin = 10
            grid.set_property "row-homogeneous", false
            grid.set_property "column-homogeneous", false
            grid.set_column_spacing 30
            grid.set_row_spacing 5
                       
            grid.attach Gtk::Label.new("Nom"), 0, 0, 1, 1
            grid.attach Gtk::Label.new("Service"), 1, 0, 1, 1
            
            for game in 0..@number_of_games-1
                grid.attach Gtk::Label.new("Manche #{game+1}"), 2+game, 0, 1, 1
            end

            @sb = []
            @names = []
            @rb = []
            for player in 0..1
                @names[player] = Gtk::Entry.new
                @names[player].signal_connect 'changed' do
                    set_match
                end
                grid.attach @names[player], 0, 1+player, 1, 1
                @rb[player] = Gtk::RadioButton.new if player == 0
                @rb[player] = Gtk::RadioButton.new(member: @rb[0]) if player > 0
                @rb[player].signal_connect 'toggled' do
                    set_match
                end
                grid.attach @rb[player], 1, 1+player, 1, 1
                @sb[player] = []
                for game in 0..@number_of_games-1
                    @sb[player][game] = Gtk::SpinButton.new(0,99,1)
                    @sb[player][game].set_max_width_chars 2
                    @sb[player][game].value = 0
                    @sb[player][game].set_name "sb_#{player}_#{game}" 
                    @sb[player][game].signal_connect 'value-changed' do |spinbutton|
                        p = spinbutton.name.split('_')[1].to_i
                        g = spinbutton.name.split('_')[2].to_i
                        if (@sb[0][g].value <=10 && @sb[1][g].value <=10 && (@sb[0][g].value + @sb[1][g].value)%2)==0 or @sb[0][g].value > 10 or @sb[1][g].value > 10
                            if @rb[0].active?
                                @rb[1].set_active(true) 
                            else
                                @rb[0].set_active(true) 
                            end
                        end
                        m = set_match
                        spinbutton.value = m.players[p][:games][g] if m.players[p][:games][g]
                        if p==0 then op=1 else op=0 end
                        @sb[op][g].value = m.players[op][:games][g] if m.players[op][:games][g]
                    end
                    grid.attach @sb[player][game], 2+game, 1+player, 1, 1
                end
            end

            @tb=[]
            for game in 0..@number_of_games-1
                @tb[game] = Gtk::ToggleButton.new(label: "Afficher")
                @tb[game].signal_connect 'toggled' do
                    set_match
                end
                grid.attach @tb[game], 2+game, 3, 1, 1
            end

            vbox.pack_start grid, :expand => true, :fill => true, :padding => 10
            add vbox           
            set_window_position :mouse
            show_all                
        end

    private

        def set_player_names(entries)
            @match.players[0][:name] = entries[0].text
            @match.players[1][:name] = entries[1].text
            @scoreboard_window.refresh_match @match
        end

        def set_match
            games = []
            for p in 0..1
                games[p] = []
                for g in 0..@number_of_games-1
                    if @tb[g].active?
                        games[p][g] = @sb[p][g].value
                    else
                        games[p][g] = nil
                    end 
                end
            end            
            players = [{name: @names[0].text, games: games[0], serve: @rb[0].active?}, {name: @names[1].text, games: games[1], serve: @rb[1].active?}]
            match = Score::MyMatch.new(id: 'match1', user_data_path: application.user_data_path, players: players, number_of_games: @number_of_games)
            @scoreboard_window.refresh_match match
            match
        end

        def load(match)
            puts "Match loaded: #{match.inspect}"
            @names[0].text = match.players[0][:name]
            @names[1].text = match.players[1][:name]
            for p in 0..1
                for g in 0..match.number_of_games-1
                    @sb[p][g].value = match.players[p][:games][g] || 0
                    @tb[g].active = match.players[p][:games][g] || false 
                end
            end
            if match.players[0][:serve]
                @previous_serve = {score: match.players[0][@current_game], player: 0}
            else
                @previous_serve = {score: match.players[1][@current_game], player: 1}
            end
            @scoreboard_window.refresh_match match
        end

        def new_match
            match = Score::MyMatch.new(id: 'match1', user_data_path: application.user_data_path, number_of_games: @number_of_games)
            load match
        end
        
    end
end