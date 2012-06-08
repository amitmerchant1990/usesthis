require 'rubygems'
require 'sinatra/base'
require 'lib/interview'
require 'slim'
require 'yaml'

class TheSetup < Sinatra::Base
        
        configure do
                begin
                        config = YAML::load_file(File.join(Dir.pwd, 'config.yml'))

                        Resource.database = Mysql2::Client.new(config[:database])                
                        Slim::Engine.set_default_options(:pretty => true)
                        
                rescue Exception => e
                        puts e
                end
        end
        
        get '/' do
                @interviews = Interview.recent(:summary => true)
                slim :index
        end
        
        get '/interviews/?' do
                @title = "Interviews"
                
                @stats = Interview.counts()
                @categories = Category.all()
                
                slim :interviews
        end
        
        get %r{/interviews/([\d]{4})/?} do |year|
                
                @interviews = Interview.by_year(year, :summary => true)
                @title = "In #{year}" if @interviews.count
                
                slim :index
        end
        
        get %r{/interviews/([a-z]+)/?} do |slug|
                @interviews = Interview.for_category_slug(slug, :summary => true)
                @title = slug.capitalize if @interviews.count
                
                slim :index
        end
        
        get '/about/?' do
                @title = "About"
                
                slim :about
        end
        
        get '/community/?' do
                slim :community
        end     
end