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
            bind_template_child 'players_bgcolor_button'
            bind_template_child 'games_bgcolor_button'
            bind_template_child 'scores_bgcolor_button'
          end
      end

      def initialize(options, parent_window, match)
        super options
        set_modal true
        set_resizable false
        set_title "Configurer le match"
        @match = match
        number_of_games_spinbutton.value = @match.number_of_games
        
        ok_button.signal_connect 'clicked' do 
          parent_window.update_settings @match
          close
        end

        cancel_button.signal_connect 'clicked' do 
          close
        end

        number_of_games_spinbutton.signal_connect 'value-changed' do  |sb|
          @match.number_of_games = sb.value
        end

        players_bgcolor_button.signal_connect 'clicked' do 
          Score::ColorChooserDialog.new({}, self).present
        end
        games_bgcolor_button.signal_connect 'clicked' do 
          Score::ColorChooserDialog.new({}, self).present
        end
        scores_bgcolor_button.signal_connect 'clicked' do 
          Score::ColorChooserDialog.new({}, self).present
        end

      end

    end
  end