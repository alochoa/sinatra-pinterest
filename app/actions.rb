helpers do
	# this helper method looks up the current user if a session exists (if logged in)
	# returns nil otherwise
	def current_user
		@current_user = User.find_by(id: session[:user_id]) if session[:user_id]
	end
end

before do
	# if user is not logged in, and is not either trying to log in or signup, redirect them to login
	redirect '/login' if !current_user && request.path != '/login' && request.path != '/signup'
end

# Homepage (Root path)
get '/' do
	@pins = Pin.all.reverse
  erb :index
end

# Route for creating a new pin, just loads one ERB file
# Has to be before /pins/:id, else :id == new
get '/pins/new' do
	erb :new_pin
end

# Ex: http://localhost:3000/pins/77
get '/pins/:id' do
	# Find pin by id (primary key)
	@pin = Pin.find(params[:id])
	erb :pin
end

get '/pins/:id/edit' do
	@pin = Pin.find(params[:id])
	erb :edit_pin
end

post '/pins/:id/update' do
	title = params[:title]
	description = params[:description]
	image = params[:image]

	pin = Pin.find(params[:id])

	pin.update_attributes title: title, description: description, image: image

	redirect "/pins/#{pin.id}"
end

# Route to which /pins/new posts to
post '/pins/create' do
	# Get form variables
	title = params[:title]
	description = params[:description]
	image = params[:image]

	# Create pin, associated with current user
	pin = current_user.pins.create title: title, description: description, image: image

	# Redirect to see new pin
	redirect "/pins/#{pin.id}"
end

# Route for posting a new comment
post '/pins/:id/comments/create' do
	body = params[:body]

	# Look up pin based on ID in route
	pin = Pin.find(params[:id])

	# Create new comment associated to pin
	pin.comments.create body: body, user_id: current_user.id
	redirect "/pins/#{pin.id}"
end

# Show login form
get '/login' do
	erb :login
end

# Show signup form
get '/signup' do
	erb :signup
end

# Process login form
post '/login' do
	# Get form parameters
	username = params[:username]
	# Could log in with username or email, pick one
	# email = params[:email]
	password = params[:password]

	# Check for user, based on username (or email, edit as necessary)
	user = User.find_by(username: username)

	# If we found a user, and the password matches, log them in
	if (user && user.password == password)
		session[:user_id] = user.id
		redirect '/'
	end

	# No user or bad credentials
	redirect '/login'
end

# Route to process signup
post '/signup' do
	# Get form parameters
	username = params[:username]
	email = params[:email]
	password = params[:password]

	# Look up user by both username and email
	user_by_email = User.find_by(email: email)
	user_by_username = User.find_by(username: username)

	if (user_by_email || user_by_username)
		#user exists, so send them back to signup
		redirect '/signup'
	else
		#create the user, log them in, and then send them to the index page
		user = User.create username: username, email: email, password: password
		session[:user_id] = user.id
		redirect '/'
	end
end

# Route to process logout
get '/logout' do
	# Delete all session variables for this user
	session.clear
	
	# Redirect them back to login
	redirect '/login'
end
