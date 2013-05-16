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

    def the_post (scope = nil)
        template = Tilt[@format].new { body_markup }
        template.render(scope)
    end

  end
  

  class Page < FileModel
    def summary
      if summary_text = metadata("summary")
        summary_text.gsub!('\n', "\n")
        convert_to_html(nil, nil, nil)
      end
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

      def latest_articles(count = 100)
        Nesta::Page.find_articles[0..count - 1]
      end

      def list_articles(articles)
        haml_tag :ol do
          articles.each do |article|
            haml_tag :li do
              haml_tag :a, article.heading, :href => url(article.abspath)
            end
          end
        end
      end

      def single_article(articles)
        haml(:single, :layout => false, :locals => { :pages => articles })
      end

      def articles_heading
        @page.metadata('articles heading') || "Projects on #{@page.heading}"
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
