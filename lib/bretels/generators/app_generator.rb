require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Bretels
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, :type => :string, :aliases => '-d', :default => 'postgresql',
      :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"

    class_option :heroku, :type => :boolean, :aliases => '-H', :default => false,
      :desc => 'Create staging and production Heroku apps'

    class_option :skip_test, :type => :boolean, :aliases => '-T', :default => true,
      :desc => 'Skip test files'

    def finish_template
      invoke :bretels_customization
      super
    end

    def bretels_customization
      invoke :customize_gemfile
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_production_environment
      invoke :create_views
      invoke :setup_database
      invoke :configure_app
      invoke :setup_stylesheets
      invoke :remove_routes_comment_lines
      invoke :setup_javascript
      invoke :setup_git
      invoke :create_heroku_apps
      invoke :outro
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :raise_delivery_errors
      build :lib_in_load_path
      build :install_spring_gem
    end

    def setup_test_environment
      say 'Setting up the test environment'
      build :add_support_files
      build :generate_rspec
      build :configure_rspec
      build :generate_factories_file
      build :add_factory_girl_lint_task
    end

    def setup_production_environment
      say 'Setting up the production environment'
      build :enable_force_ssl
      build :add_cdn_settings
      build :enable_rack_deflater
    end

    def create_views
      say 'Creating bretel views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_application_layout
    end

    def customize_gemfile
      build :replace_gemfile
      build :set_ruby_to_version_being_used
      bundle_command 'install'
    end

    def setup_database
      say 'Setting up database'

      if 'postgresql' == options[:database]
        build :use_postgres_config_template
      end
    end

    def configure_app
      say 'Configuring app'
      build :configure_action_mailer
      build :raise_unpermitted_params
      build :configure_time_zone
      build :configure_time_formats
      build :configure_dutch_language
      build :setup_foreman
    end

    def setup_stylesheets
      say 'Set up stylesheets'
      build :setup_stylesheets
    end

    def setup_git
      say 'initializing git'
      invoke :setup_gitignore
      invoke :init_git
    end

    def create_heroku_apps
      if options[:heroku]
        say 'Creating Heroku apps'
        build :create_heroku_apps
      end
    end

    def setup_gitignore
      build :gitignore_files
    end

    def init_git
      build :init_git
    end

    def setup_javascript
      build :replace_application_js
      build :generate_package_json
      build :copy_browserify_files
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def outro
      say 'Done. Congratulations! Please run bin/setup to setup database!'
    end

    protected

    def get_builder_class
      Bretels::AppBuilder
    end
  end
end
