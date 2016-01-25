require_relative '../Encryptor'
require 'tempfile'
require "pry"


describe Encryptor do
  let(:encryptor) { Encryptor.new }

  describe "string based encryption and decryption" do
    it "allows a string to be encrypted" do
      expect(encryptor.encrypt("Secrets")).to eq("Srpcred") 
      expect(encryptor.encrypt("Hello World")).to eq("Hryy` W`cyq")
    end

    it "allows an encrypted string to be decrypted" do
      expect(encryptor.decrypt("Srpcred")).to eq("Secrets")
      expect(encryptor.decrypt("Hryy` W`cyq")).to eq("Hello World")
    end
  end

  describe "file based encryption and decryption" do
    let(:tf) { Tempfile.open("secret") }

    before do
      tf.puts "This is the secret file."
      tf.puts "Testing the Ruby Encryptor class."
      tf.close
    end

    after do
      FileUtils.rm_rf(tf.path + ".enc")
      FileUtils.rm_rf(tf.path + ".enc.dec")
      tf.unlink
    end

    it "allows a file to be encrypted" do
      orig = File.read(tf.path)
      encryptor.encrypt_file(tf.path)
      enc = File.read(tf.path + ".enc")
      encryptor.decrypt_file(tf.path + ".enc")
      dec = File.read(tf.path + ".enc.dec")

      expect(orig).not_to eq(enc)
      expect(orig).to eq(dec)
    end
  end
end
