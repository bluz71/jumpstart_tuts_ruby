require_relative '../lib/micro_blogger'

class MockBitly
end

class MockUser
  def initialize(name)
    @name = name
  end

  def screen_name
    @name
  end

  def tweet
    @name
  end
end

class MockClient
  def update(message)
    message
  end

  def followers
    ["jack", "jill"]
  end

  def following
    ["don", "betty"]
  end

  def user(name)
    MockUser.new(name)
  end
end

describe MicroBlogger do
  let(:micro_blogger) { MicroBlogger.new }

  before do
    allow_any_instance_of(MicroBlogger).to \
      receive(:initialize_client).and_return(MockClient.new)
    allow_any_instance_of(MicroBlogger).to \
      receive(:initialize_bitly).and_return(MockBitly.new)
  end

  context "when processing commands" do
  end

  context "when tweeting" do
    it "with short valid length message" do
      expect(micro_blogger.tweet("hello world")).to eq("hello world")
    end

    it "with long valid length message" do
      expect(micro_blogger.tweet("a" * 140 )).to eq("a" * 140)
    end

    it "with invalid length message (> 140 chars)" do
      expect(STDOUT).to receive(:puts).with("Message 'aaa..' is too long")
      micro_blogger.tweet("a" * 141)
    end
  end

  context "when direct messaging" do
    it "to a follower" do
      expect(micro_blogger.dm("jack", "hello jack")).to eq("d @jack hello jack")
    end

    it "to a non-follower" do
      expect(STDOUT).to receive(:puts).with("don does not follow you, can not send direct message")
      micro_blogger.dm("don", "hello don")
    end
  end

  it "with a message" do
    expect(micro_blogger.spam_my_followers("hello all")).to eq(["jack", "jill"])
  end
end
