helpers do
	def current_user
		@current_user = User.find_by(id: session[:user_id]) if session[:user_id]
	end
end

before do
	redirect '/login' if !current_user && request.path != '/login'
end

# Homepage (Root path)
get '/' do
  erb :index
end

# http://mycoolapp.com/pins/77
get '/pins/:id' do
	@pin = Pin.find(params[:id])
	erb :pin
end

get '/login' do
	erb :login
end

post '/login' do
	username = params[:username]
	password = params[:password]

	user = User.find_by(username: username)
	if (user && user.password == password)
		session[:user_id] = user.id
		redirect '/pins'
	end

	redirect '/login'
end

get '/logout' do
	session.clear
	redirect '/'
end
