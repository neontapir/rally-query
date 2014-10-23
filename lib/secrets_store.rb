require 'base64'
require 'encryptor'
require 'yaml'
require_relative('logging_provider')

class SecretsStore
  include LoggingProvider
  attr_reader :filename, :system

  def initialize(yaml_file = File.expand_path('../your_credentials.yml', File.dirname(__FILE__)), system = 'Rally')
    @system = system
    @filename = yaml_file
    @secret_key = 'xyzzy-unicorn'
    log.debug("Starting SecretsStore with parameters yaml_file=#{yaml_file}, system=#{system}")
  end

  def get_password(system = @system)
    value = get 'password', system
    value.nil? ? nil : value.split(':')
  end

  def get(key, system = @system)
    return nil unless File.file? @filename

    contents = YAML.load_file(@filename)

    raise "No entry found for #{system}" if contents[system].nil?

    encrypted_value = contents[system][key]
    #puts "Encrypted value for #{system} #{key} is #{encrypted_value}"

    raise "No entry found for #{system} #{key}" if encrypted_value.nil?

    extracted_encrypted_value = Base64.decode64(encrypted_value)

    decrypted_value = Encryptor.decrypt(extracted_encrypted_value, :key => @secret_key, :algorithm => 'aes-256-ecb')
    #puts "Decrypted value for #{system} #{key} is #{encrypted_value} -> #{extracted_encrypted_value} -> #{decrypted_value}"

    decrypted_value
  end

  def set_password (value, system = @system)
    set 'password', value, system
  end

  def set(key, value, system = @system)
    encrypted_value = Encryptor.encrypt(value, :key => @secret_key, :algorithm => 'aes-256-ecb')
    encoded_encrypted_value = Base64.encode64(encrypted_value)
    #puts "Encrypted value for #{system} #{key} is #{value} -> #{encrypted_value} -> #{encoded_encrypted_value}"

    if File.file? @filename
      contents = YAML.load_file(@filename)
      if contents[system].nil?
        contents[system] = { key => encoded_encrypted_value }
      else
        contents[system][key] = encoded_encrypted_value
      end
    else
      contents = { system => { key => encoded_encrypted_value } }
    end

    File.open(@filename, 'w') {|f| f.write contents.to_yaml }
  end
end