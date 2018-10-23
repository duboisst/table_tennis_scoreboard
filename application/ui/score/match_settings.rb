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
            bind_template_child 'players_bgcolor_button'
            bind_template_child 'games_bgcolor_button'
            bind_template_child 'scores_bgcolor_button'
          end
      end

      attr_reader :settings

      def initialize(options, settings)
        super options
        set_modal true
        set_resizable false
        set_title "Configurer le match"
        @settings = settings
        number_of_games_spinbutton.value = @settings[:number_of_games]

        ok_button.signal_connect 'clicked' do 
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

        players_font_button.signal_connect 'clicked' do 
          dialog = Gtk::FontChooserDialog.new(title: "Police de caractères des joueurs", parent: self)
          dialog.set_font @settings[:players_font] if @settings[:players_font]
          if dialog.run == Gtk::ResponseType::OK
            @settings[:players_font] = dialog.font
          end
          dialog.destroy;
        end
        players_bgcolor_button.signal_connect 'clicked' do 
          dialog = Gtk::ColorChooserDialog.new(title: "Couleur de fond des joueurs", parent: self)
          dialog.set_rgba @settings[:players_color] if @settings[:players_color]
          if dialog.run == Gtk::ResponseType::OK
            @settings[:players_color] = dialog.rgba
          end
          dialog.destroy;
        end
        games_bgcolor_button.signal_connect 'clicked' do 
          dialog = Gtk::ColorChooserDialog.new(title: "Couleur de fond des manches", parent: self)
          dialog.set_rgba @settings[:games_color] if @settings[:games_color]
          if dialog.run == Gtk::ResponseType::OK
            @settings[:games_color] = dialog.rgba
          end
          dialog.destroy;
        end
        scores_bgcolor_button.signal_connect 'clicked' do 
          dialog = Gtk::ColorChooserDialog.new(title: "Couleur de fond des scores", parent: self)
          dialog.set_rgba @settings[:scores_color] if @settings[:scores_color]
          if dialog.run == Gtk::ResponseType::OK
            @settings[:scores_color] = dialog.rgba
          end
          dialog.destroy;
        end

      end

    end
  end