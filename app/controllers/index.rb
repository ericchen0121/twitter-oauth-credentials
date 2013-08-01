get '/' do
  # session.delete(:request_token)
  erb :index
end

get '/sign_in' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url
end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # token + secret, username and id
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)

  # at this point in the code is where you'll need to create your user account and store the access token
  user = User.where(username: @access_token.params[:screen_name]).first || User.create(username: @access_token.params[:screen_name], oauth_token: @access_token.token, oauth_secret: @access_token.secret)

  session[:user_id] = user.id

  erb :index
end


post '/tweets' do
  puts "XXXXXXXXXXXXX"
  puts "PARAMS: #{params}"
  tweet = Tweet.create(params[:tweet])
  twittertweet = TweetWorker.perform(tweet.id) #Twitter::Tweet object
  jobid = TweetWorker.perform_async(twittertweet.id)
  puts "twitter tweet: #{twittertweet.inspect}"
  puts "job id: #{jobid}"
  # content_type :json
  # {jobid: jobid}

  redirect "/status/#{jobid}"
end

get '/status/:job_id' do |job_id|
  # return the status of a job to an AJAX call
  @completedjob = job_is_complete(job_id)
  erb :status
end
