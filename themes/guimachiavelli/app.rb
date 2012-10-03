require 'kramdown'
require 'compass'
require 'susy'
require 'haml'
require 'sass'


module Nesta

  class FileModel
    def thumbnail
      metadata('thumbnail')
    end

    def project_link
      metadata('project link')
    end

  end
  class App
    nesta_config = YAML::load(File.open(File.join("config", "config.yml")))
    use Rack::Static, :urls => ['/' + nesta_config['theme']], :root => 'themes/' + nesta_config['theme'] + '/public'
    configure do
      # Default Haml format is :xhtml. Let's change that.
      set :haml, { :format => :html5 }
    end

    helpers do
      def path
        request.path
      end

      def current_url
        request.url
      end
    end

    configure :production do
      set :haml, { :ugly => true }
    end

    get '/css/:sheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      cache sass(params[:sheet].to_sym, Compass.sass_engine_options)
    end

    Tilt.prefer Tilt::KramdownTemplate

  end
end