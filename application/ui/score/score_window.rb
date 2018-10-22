module Score
    class ScoreWindow < Gtk::Window

      def initialize(number_of_games)
        super 0
        init_ui number_of_games
        show_all
      end

      def init_ui(number_of_games)
        @css_provider = Gtk::CssProvider.new
        @css_provider.load(data: ".game, .score { \
                                    color: white; \
                                    font-weight: bold; \
                                 } \
                                 .player { \
                                    color: white; \
                                    font-weight: bold; \
                                 }")
        set_keep_above true
        set_resizable false
        set_title "Scores"
        set_decorated true
        set_deletable false
        set_window_position :center
        override_background_color(0, Gdk::RGBA.parse('white'))

        hbox = Gtk::Box.new :horizontal, 2

        @players_name = []
        @players_serve = []
        @games = []
        @scores = []

        @grid = Gtk::Grid.new
        @grid.margin = 2
        @grid.set_property "row-homogeneous", true
        @grid.set_property "column-homogeneous", false
        @grid.set_column_spacing 1
        @grid.set_row_spacing 1

        for p in 0..1
          display_player p
          display_games p        
          @scores << []
          for g in 0..number_of_games-1
            display_score p, g
          end
        end
        add @grid
      end

      def refresh_match(match)
        for p in 0..1
          @players_name[p].text = match.players[p][:name]
          @players_serve[p].visible = match.players[p][:serve] || false
          @games[p].text = match.player_games(p).to_s

          for g in 0..match.number_of_games-1
            if match.players[p][:games][g]
              @scores[p][g].text = "%.0f" % match.players[p][:games][g]
            else
              @scores[p][g].text = ''
            end
          end
        end
      end

      private

      def display_player(p)
        @players_name << Gtk::Label.new("Player#{p}")
        @players_name[p].set_xalign 0
        @players_name[p].style_context.add_class 'player'
        @players_name[p].style_context.add_provider(@css_provider, Gtk::StyleProvider::PRIORITY_USER)
        @players_name[p].set_margin_right 25
        @players_name[p].set_margin_top 5
        @players_name[p].set_margin_bottom 5
        @players_name[p].set_margin_left 5
        b = Gtk::Box.new :vertical, 0
        b.set_center_widget @players_name[p]
        b.margin = 0
        bh = Gtk::Box.new :horizontal, 0
        bh.pack_start b, :expand => false, :fill => false, :padding => 0
        bh.override_background_color 0, Gdk::RGBA.parse('#3664c9')

        @players_serve << Gtk::Image.new(file: "resources/ui/serve.png")
        @players_serve[p].set_xalign 0.5
        @players_serve[p].style_context.add_class 'serve'
        @players_serve[p].style_context.add_provider(@css_provider, Gtk::StyleProvider::PRIORITY_USER)
        @players_serve[p].margin = 5
        b = Gtk::Box.new :vertical, 0
        b.set_center_widget @players_serve[p]
        b.override_background_color 0, Gdk::RGBA.parse('#3664c9')
        b.set_size_request 20, -1
        b.margin = 0
        bh.pack_end b, :expand => false, :fill => false, :padding => 0
        @grid.attach bh, 0, p, 1, 1
      end

      def display_games(p)
        @games << Gtk::Label.new("G#{p}")
        @games[p].set_xalign 0.5
        @games[p].style_context.add_class 'game'
        @games[p].style_context.add_provider(@css_provider, Gtk::StyleProvider::PRIORITY_USER)
        @games[p].set_margin_right 7
        @games[p].set_margin_top 5
        @games[p].set_margin_bottom 5
        @games[p].set_margin_left 7
        b = Gtk::Box.new :vertical, 0
        b.override_background_color(0, Gdk::RGBA.parse('#df2629'))
        b.set_center_widget @games[p]
        b.margin = 0
        @grid.attach b, 2, p, 1, 1
      end

      def display_score(p, g)
        @scores[p] << Gtk::Label.new("#{p}#{g}")
        @scores[p][g].set_xalign 1
        @scores[p][g].style_context.add_class 'score'
        @scores[p][g].style_context.add_provider(@css_provider, Gtk::StyleProvider::PRIORITY_USER)
        @scores[p][g].set_margin_right 8
        @scores[p][g].set_margin_top 5
        @scores[p][g].set_margin_bottom 5
        @scores[p][g].set_margin_left 8
        b = Gtk::Box.new :vertical, 0
        b.override_background_color 0, Gdk::RGBA.parse('#3664c9')
        b.set_center_widget @scores[p][g]
        b.margin = 0
        @grid.attach b, 3+g, p, 1, 1
      end

    end
  end