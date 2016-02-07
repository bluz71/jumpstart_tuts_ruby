# Gems required:
#   % gem install jumpstart_auth bitly
#
# Test Twitter user: phesledetr1
#                    phesledetr@thrma.com :: TheJ**..........

require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    @client = initialize_client
    @bitly = initialize_bitly
  end

  def tweet(message)
    if message.length > 140
      puts "Message '#{message[0..2]}..' is too long"
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

  def shorten_url(original_url)
    puts "Shortening this URL: #{original_url}"
    @bitly.shorten(original_url).short_url
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
      when "s"
        shorten_url(parts[1..-1].join(" "))
      when "turl"
        tweet(parts[1..-2].join(" ") + shorten_url(parts[-1]))
      else
        puts "Sorry, I don't know about #{command}"
      end
    end
  end

  private

    def initialize_client
      JumpstartAuth.twitter
    end

    def initialize_bitly
      Bitly.use_api_version_3
      Bitly.new("hungryacademy", "R_430e9f62250186d2612cca76eee2dbc6")
    end

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
