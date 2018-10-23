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
            @scoreboard_window = ScoreWindow.new
            new_match
        end

        def init_ui
            self.children.each do |widget|
                self.remove widget
            end

            set_title 'Table tennis scoreboard'
            set_resizable false

            vbox = Gtk::Box.new :vertical, 2
        
            mb = Gtk::MenuBar.new
            filemenu = Gtk::Menu.new
            file = Gtk::MenuItem.new label: "File"
            file.set_submenu filemenu
            filemenu.append(new_menu = Gtk::MenuItem.new(label: "Nouveau match"))
            filemenu.append(load_menu = Gtk::MenuItem.new(label: "Charger un match"))
            filemenu.append(save_menu = Gtk::MenuItem.new(label: "Sauvegarder le match"))
            filemenu.append(match_settings_menu = Gtk::MenuItem.new(label: "Configurer le match..."))
            new_menu.signal_connect 'activate' do
                new_match
            end
            load_menu.signal_connect 'activate' do
                load_match
            end
            save_menu.signal_connect 'activate' do
                @match.save!
            end
            match_settings_menu.signal_connect 'activate' do
                dialog = Score::MatchSettingsWindow.new({parent: self},  @match)
                if dialog.run == Gtk::ResponseType::OK
                    col = dialog.players_color.to_s
                    puts "players color: #{col}"
                end
                dialog.destroy;    
            end

            mb.append file
    
            vbox.pack_start mb, :expand => false, :fill => false, :padding => 0
            
            grid = Gtk::Grid.new
            grid.margin = 10
            grid.set_property "row-homogeneous", false
            grid.set_property "column-homogeneous", false
            grid.set_column_spacing 30
            grid.set_row_spacing 5
                       
            grid.attach Gtk::Label.new("Nom"), 0, 0, 1, 1
            grid.attach Gtk::Label.new("Service"), 1, 0, 1, 1
            
            for game in 0..@match.number_of_games-1
                grid.attach Gtk::Label.new("Manche #{game+1}"), 2+game, 0, 1, 1
            end

            @sb = []
            @names = []
            @rb = []
            for player in 0..1
                @names[player] = Gtk::Entry.new
                @names[player].text = @match.players[player][:name]
                @names[player].signal_connect 'changed' do
                    update_match
                end
                grid.attach @names[player], 0, 1+player, 1, 1
                @rb[player] = Gtk::RadioButton.new if player == 0
                @rb[player] = Gtk::RadioButton.new(member: @rb[0]) if player > 0
                @rb[player].signal_connect 'toggled' do
                    update_match
                end
                grid.attach @rb[player], 1, 1+player, 1, 1
                @sb[player] = []
                for game in 0..@match.number_of_games-1
                    @sb[player][game] = Gtk::SpinButton.new(0,99,1)
                    @sb[player][game].set_max_width_chars 2
                    @sb[player][game].value = @match.players[player][:games][game] || 0
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
                        m = update_match
                        spinbutton.value = m.players[p][:games][g] if m.players[p][:games][g]
                        if p==0 then op=1 else op=0 end
                        @sb[op][g].value = m.players[op][:games][g] if m.players[op][:games][g]
                    end
                    grid.attach @sb[player][game], 2+game, 1+player, 1, 1
                end
            end

            @tb=[]
            for game in 0..@match.number_of_games-1
                @tb[game] = Gtk::ToggleButton.new(label: "Afficher")
                @tb[game].active = @match.players[0][:games][game] || @match.players[1][:games][game] || false 
                @tb[game].signal_connect 'toggled' do
                    update_match
                end
                grid.attach @tb[game], 2+game, 3, 1, 1
            end

            vbox.pack_start grid, :expand => true, :fill => true, :padding => 10
            add vbox           
            set_window_position :mouse
            show_all      
        end

        def update_settings(match)
            @match = match
            @scoreboard_window.match = @match
            init_ui
        end

    private

        def update_match
            players = [{name: @names[0].text, games: [], serve: @rb[0].active?}, {name: @names[1].text, games: [], serve: @rb[1].active?}]
            for p in 0..1
                for g in 0..@match.number_of_games-1
                    if @tb[g].active?
                        players[p][:games][g] = @sb[p][g].value
                    else
                        players[p][:games][g] = nil
                    end 
                end
                players[p][:serve] = @rb[p].active?
            end            
            @match.players = players
            @scoreboard_window.match = @match
            @match
        end

        def new_match
            @match = Score::MyMatch.new(id: 'match1', user_data_path: application.user_data_path, number_of_games: 5)
            @scoreboard_window.match =  @match
            init_ui
        end

        def load_match
            @match = Score::MyMatch.new(user_data_path: application.user_data_path, filename: '.gtk-score/match1.json')
            @scoreboard_window.match = @match
            init_ui
        end
            
    end
end