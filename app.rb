## file: app.rb
 
require 'sinatra'
require 'seraph'
require 'sinatra/flash'
 
enable :sessions




 
get "/time" do
  Time.now.to_s
end

get '/' do
  erb :index
end
 
get "/auth" do
  redirect client.authorization_code.auth_uri(:redirect_uri => redirect_uri, :scope => "read write")
end
get "/categories"do
  @cats= client(session[:access_token]).get("/api/v1/categories.json")
  erb :categories
end

post "/elements/create" do
  client(session[:access_token]).post("/api/v1/categories/#{params[:category_id]}/elements.json" , {"element[value]"=>params[:value]})
  flash[:notice]="Element created!"
  redirect "/categories"
end

get '/oauth2callback' do
  @access_token = client.authorization_code.get_token(:code => params[:code], :redirect_uri => redirect_uri)
  session[:access_token] = @access_token
  redirect "/categories"
end

get "/logout" do
  session[:access_token]=nil
  redirect "/"
end



helpers do 
  def redirect_uri
    uri = URI.parse(request.url)
    uri.path = '/oauth2callback'
    uri.query = nil
    puts uri.to_s
    uri.to_s
  end
  
  
  
  def client(access_token=nil)
    api_client="c40ce0a97c6215ed4a3d59f4c417e4bcb71073ffa5449960f99f3a44bf49f1d5"
    api_secret="867ad47ed53decde98b62a6f81735d9746c90d74c8af0a39d0536e2bac497cc5"
    client ||= Seraph::Client.new('http://localhost:3000',
                                  api_client, 
                                  api_secret, 
                                  :authorize_path=>"/oauth/authorize", 
                                  :token_path=>"/oauth/token",
                                  :access_token=>access_token
                                  )
  end
end