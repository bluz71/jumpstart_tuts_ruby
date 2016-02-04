# Gems required:
#   % gem install jumpstart_auth
#
# Test Twitter user: phesledetr1
#                    phesledetr@thrma.com :: TheJ**..........

require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length > 140
      puts "Message '#{message[0..5]}' too long, must be less than or equal to 140 characters."
    else
      @client.update(message)
    end
  end

  def dm(target, message)
    if followers_list.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "#{target} does not follow you, can not send direct message"
    end
  end

  def spam_my_followers(message)
    followers_list.each { |follower| dm(follower, message) }
  end

  def everyones_last_tweet
    tweets = last_tweets
    tweets.keys.sort.each do |user|
      tweet = tweets[user]
      print "#{user} said this on #{tweet.created_at.strftime("%A, %b %d")}:\n"
      print "#{tweet.text}\n\n"
    end
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      print "Enter command: "
      input = gets.chomp
      parts = input.split
      command = parts[0]
      case command
      when "q"
        puts "Goodbye"
      when "t"
        tweet(parts[1..-1].join(" "))
      when "dm"
        dm(parts[1], parts[2..-1].join(" "))
      when "spam"
        spam_my_followers(parts[1..1].join(" "))
      when "last"
        everyones_last_tweet
      else
        puts "Sorry, I don't know about #{command}"
      end
    end
  end

  private

    def followers_list
      @client.followers.map { |follower| @client.user(follower).screen_name }
    end

    def following_list
      @client.following.map { |follower| @client.user(follower).screen_name }
    end

    def last_tweets
      tweets = {}
      following_list.each do |following|
        tweets[following] = @client.user(following).tweet
      end
      tweets
    end

end

blogger = MicroBlogger.new
blogger.run