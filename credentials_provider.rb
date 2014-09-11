require 'base64'
require 'encryptor'
require 'yaml'

class CredentialsProvider
  attr_reader :filename

  def initialize(yaml_file = File.dirname(__FILE__) + '/your_credentials.yml')
    @filename = yaml_file
    @secret_key = 'xyzzy-unicorn'
  end

  def read_static
    decoded = Base64.decode64 'Y2R1cmZlZUBnaHguY29tOnJseVNoMW55IQo='
    @credentials = decoded.strip.split(':')
  end

  def get
    return '' unless File.file? @filename
    account_config = YAML.load_file(@filename)
    account_password = Encryptor.decrypt(Base64.decode64(account_config['password']), :key => @secret_key, :algorithm => 'aes-256-ecb')
    @credentials = account_password.to_s.split(':')
  end

  def set(value)
    password = Base64.encode64(Encryptor.encrypt(value, :key => @secret_key, :algorithm => 'aes-256-ecb'))
    hash = { 'password' => password }
    File.open(@filename, 'w') {|f| f.write hash.to_yaml }
  end
end