require 'singleton'

class Preferences
  class << self
    # A hash of all default values for the user defaults
    def default_values
      @default_values ||= {}
    end
    
    # Registers the default values with NSUserDefaults.standardUserDefaults
    # Called at the end of evaluating model/preferences.rb
    def register_default_values!
      NSUserDefaults.standardUserDefaults.registerDefaults(:Preferences => default_values)
    end
  end
  
  class AbstractPreferencesSection
    include Singleton
    
    class << self
      # The key in the preferences that represents the section class.
      #
      #   Preferences::General.section_defaults_key # => :General
      def section_defaults_key
        @section_defaults_key ||= name.split('::').last.to_sym
      end
      
      # The default values defined by this section.
      def section_default_values
        Preferences.default_values[section_defaults_key] ||= {}
      end
      
      # Defines a reader and writer method for a user defaults key for this section.
      #
      #  # Defines #confirm_quit and #confirm_quit= and <tt>true</tt> as it's default value.
      #  defaults_accessor :confirm_quit, true
      def defaults_accessor(name, default_value)
        section_default_values[name] = default_value
        key = "Preferences.#{section_defaults_key}.#{name}"
        
        class_eval do
          define_method(name) do
            NSUserDefaults.standardUserDefaults[key].to_ruby
            #section_user_defaults[name].to_ruby
          end
          
          define_method("#{name}=") do |value|
            # defaults = section_user_defaults.to_ruby
            # defaults[name] = value
            # self.section_user_defaults = defaults
            # value
            NSUserDefaults.standardUserDefaults[key] = value
          end
        end
      end
    end
    
    # The reader method for the preferences for this section.
    def section_user_defaults
      NSUserDefaults.standardUserDefaults[:Preferences][self.class.section_defaults_key]
    end
    
    # The writer method for the preferences for this section.
    def section_user_defaults=(section_user_defaults)
      defaults = NSUserDefaults.standardUserDefaults[:Preferences].to_ruby.merge(self.class.section_defaults_key => section_user_defaults)
      NSUserDefaults.standardUserDefaults.setObject_forKey(defaults, :Preferences)
    end
  end
end