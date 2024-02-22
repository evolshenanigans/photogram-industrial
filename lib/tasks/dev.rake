desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do
  p "Creating sample data"

  if Rails.env.development?
    FollowRequest.destroy_all
    Comment.destroy_all
    Like.destroy_all
    Photo.destroy_all
    User.destroy_all
  end

  12.times do
    name = Faker::Name.first_name # Fixed: Assign generated name to a variable
    user = User.create( # Fixed: Assign the created user to a variable
      email: "#{name}@example.com",
      password: "password", # Uncommented and added password
      username: name,
      private: [true, false].sample
    )
    p user.errors.full_messages # Fixed: Correct variable name
  end
  users = User.all
  
  users.each do |first_user|
    users.each do |second_user|
      next if first_user == second_user
      if rand < 0.75
        first_user.sent_follow_requests.create(
          recipient: second_user,
          status: FollowRequest.statuses.keys.sample
        )
      end
        
      if rand < 0.75
        second_user.sent_follow_requests.create(
          recipient: first_user,
          status: FollowRequest.statuses.keys.sample
        )
      end
    end
  end
  
  users.each do |user| # Fixed: Correct placement of the loop
    rand(15).times do
      photo = user.own_photos.create(
        caption: Faker::Quote.jack_handey,
        image: "https://robohash.org/#{rand(9999)}"
      )
      user.followers.each do |follower|
        if rand < 0.5 && !photo.fans.include?(follower)
          photo.fans << follower
        end
        if rand < 0.25
          photo.comments.create(
            body: Faker::Quote.jack_handey,
            author: follower 
          )
        end
      end
    end
  end

  p "there are now #{User.count} users."
  p "there are now #{FollowRequest.count} follow requests."
  p "there are now #{Photo.count} photos."
  p "there are now #{Like.count} likes."
  p "there are now #{Comment.count} comments."
end
