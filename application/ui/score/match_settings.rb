module Score
    class MatchSettingsWindow < Gtk::Dialog
      # Register the class in the GLib world
      type_register

      class << self
          def init
            # Set the template from the resources binary
            set_template resource: '/com/sds/gtk-score/ui/match_settings.ui'
            bind_template_child 'number_of_games_spinbutton'
            bind_template_child 'ok_button'
            bind_template_child 'cancel_button'
            bind_template_child 'players_font_button'
            bind_template_child 'players_color_button'
            bind_template_child 'players_bgcolor_button'
            bind_template_child 'games_font_button'
            bind_template_child 'games_color_button'
            bind_template_child 'games_bgcolor_button'
            bind_template_child 'scores_font_button'
            bind_template_child 'scores_color_button'
            bind_template_child 'scores_bgcolor_button'
          end
      end

      attr_reader :settings

      def initialize(options, settings)
        super options
        set_modal true
        set_resizable false
        set_title "Configurer le match"
        set_position Gtk::WindowPosition::MOUSE
        @settings = settings
        number_of_games_spinbutton.value = @settings[:number_of_games]

        ok_button.signal_connect 'clicked' do 
          puts "@settings: #{@settings.inspect}"
          response Gtk::ResponseType::OK
          close
        end

        cancel_button.signal_connect 'clicked' do 
          response Gtk::ResponseType::CANCEL
          close
        end

        number_of_games_spinbutton.signal_connect 'value-changed' do  |sb|
          @settings[:number_of_games] = sb.value
        end

        signal_connect_font_buttons [
          {button: players_font_button, title: "Police de caractères des joueurs", setting: :players_font},
          {button: games_font_button, title: "Police de caractères des manches", setting: :games_font},
          {button: scores_font_button, title: "Police de caractères des scores", setting: :scores_font}
        ]

        signal_connect_color_buttons [
          {button: players_color_button, title: "Couleur des joueurs", setting: :players_color},
          {button: games_color_button, title: "Couleur des manches", setting: :games_color},
          {button: scores_color_button, title: "Couleur des scores", setting: :scores_color},
          {button: players_bgcolor_button, title: "Couleur de fond des joueurs", setting: :players_bgcolor},
          {button: games_bgcolor_button, title: "Couleur de fond des manches", setting: :games_bgcolor},
          {button: scores_bgcolor_button, title: "Couleur de fond des scores", setting: :scores_bgcolor}
        ]

      end
private

      def signal_connect_font_buttons(options)
        puts "options: #{options.inspect}"
        options.each do |option|
          option[:button].signal_connect 'clicked' do 
            dialog = Gtk::FontChooserDialog.new(title: option[:title], parent: self)
            dialog.set_font @settings[option[:setting]] if @settings[option[:setting]]
            if dialog.run == Gtk::ResponseType::OK
              @settings[option[:setting]] = dialog.font
            end
            dialog.destroy;
          end
        end
      end

      def signal_connect_color_buttons(options)
        options.each do |option|
          puts "option: #{option.inspect}"
          option[:button].signal_connect 'clicked' do 
            dialog = Gtk::ColorChooserDialog.new(title: option[:title], parent: self)
            puts "clicked avant set : #{@settings[option[:setting]].inspect}"
            dialog.set_rgba @settings[option[:setting]] if @settings[option[:setting]]
            if dialog.run == Gtk::ResponseType::OK
              puts "clicked dans ok - rgba: #{dialog.rgba.inspect}"
              @settings[option[:setting]] = dialog.rgba
            end
            dialog.destroy;
          end
        end
      end

    end
  end