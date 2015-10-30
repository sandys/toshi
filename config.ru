STDOUT.sync = STDERR.sync = true

require_relative 'config/environment'

require "toshi/web/www"
require "toshi/web/api"
require "toshi/web/websocket"
require 'sidekiq/web'

use Rack::CommonLogger
use Bugsnag::Rack



  Sidekiq::Web.use Rack::Auth::Basic, 'Sidekiq' do |username, password|
    #username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
    username == "sss" && password == "sss" 
  end


class MyApp
  def initialize
	@app = Rack::URLMap.new(
	  '/'          => Toshi::Web::WWW,
	  '/sidekiq' => Sidekiq::Web,
	  '/api/v0'    => Toshi::Web::Api,
	)
	@app = Toshi::Web::WebSockets.new(@app)
	#run @app
 
  end

  def call(env)
    env['SCRIPT_NAME'] = '/api'
    @app.call(env)
  end
end

run MyApp.new
