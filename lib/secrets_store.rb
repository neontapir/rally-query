require 'base64'
require 'encryptor'
require 'yaml'

class SecretsStore
  attr_reader :filename, :system

  def initialize(yaml_file = File.expand_path('../your_credentials.yml', File.dirname(__FILE__)), system = 'Rally')
    @system = system
    @filename = yaml_file
    @secret_key = 'xyzzy-unicorn'
  end

  def get(key, system = @system)
    return '' unless File.file? @filename

    contents = YAML.load_file(@filename)
    raise "No entry found for #{system} -> #{key}" if contents[system][key].nil?

    account_password = Encryptor.decrypt(Base64.decode64(contents[system][key]), :key => @secret_key, :algorithm => 'aes-256-ecb')
    @credentials = account_password.to_s.split(':')
  end

  def set(key, value, system = @system)
    password = Base64.encode64(Encryptor.encrypt(value, :key => @secret_key, :algorithm => 'aes-256-ecb'))

    if File.file? @filename
      contents = YAML.load_file(@filename)
      contents[system] = { key => password }
    else
      contents = { system => { key => password } }
    end

    File.open(@filename, 'w') {|f| f.write contents.to_yaml }
  end
end