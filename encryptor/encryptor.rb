class Encryptor
  def cipher(rot)
    keys = ('_'..'z').to_a
    values = keys.rotate(rot)
    Hash[keys.zip(values)]
  end

  def encrypt(content, rot = 13)
    ci = cipher(rot)
    encrypted = content.split("").map do |c|
      ci.has_key?(c) ? ci[c] : c
    end
    encrypted.join
  end

  def decrypt(encrypted, rot = 13)
    ci = cipher(rot)
    content = encrypted.split("").map do |c|
      ci.has_value?(c) ? ci.key(c) : c
    end
    content.join
  end

  def encrypt_file(filename, rot = 13)
    File.open(filename + ".enc", "w") do |f1|
      File.open(filename) do |f2|
        f2.each do |line|
          f1.write(encrypt(line, rot))
        end
      end
    end
  end

  def decrypt_file(filename, rot = 13)
    File.open(filename + ".dec", "w") do |f1|
      File.open(filename) do |f2|
        f2.each do |line|
          f1.write(decrypt(line, rot))
        end
      end
    end
  end
end
