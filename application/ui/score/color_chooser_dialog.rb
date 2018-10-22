module Score
    class ColorChooserDialog < Gtk::ColorChooserDialog
      # Register the class in the GLib world
      type_register

      class << self
          def init
            # Set the template from the resources binary
            set_template resource: '/com/sds/gtk-score/ui/color_chooser_dialog.ui'
          end
      end

      def initialize(options, parent_window, settings)
        super options
        set_modal true
        set_resizable false
        set_title "Choisir la couleur"
        @settings = settings
        
      end

    end
  end