require 'base64'
require 'encryptor'
require 'yaml'

class CredentialsProvider
  attr_reader :filename

  def initialize(yaml_file = File.expand_path('../your_credentials.yml', File.dirname(__FILE__)))
    @filename = yaml_file
    @secret_key = 'xyzzy-unicorn'
  end

  def get_password(system)
    key = get_key system
    get key
  end

  def set_password(system, value)
    key = get_key system
    set(key, value)
  end

  private

  def get_key(system)
    "#{system.to_s.downcase}-password"
  end

  def get(key)
    return '' unless File.file? @filename

    contents = YAML.load_file(@filename)
    raise "No entry found for #{key}" if contents[key].nil?

    account_password = Encryptor.decrypt(Base64.decode64(contents[key]), :key => @secret_key, :algorithm => 'aes-256-ecb')
    @credentials = account_password.to_s.split(':')
  end

  def set(key, value)
    password = Base64.encode64(Encryptor.encrypt(value, :key => @secret_key, :algorithm => 'aes-256-ecb'))

    if File.file? @filename
      contents = YAML.load_file(@filename)
      contents[key] = password
    else
      contents = { key => password }
    end

    File.open(@filename, 'w') {|f| f.write contents.to_yaml }
  end
end