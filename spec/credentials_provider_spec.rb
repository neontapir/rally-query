require 'rspec'

require_relative '../lib/credentials_provider'

describe 'Credentials provider' do
  before :all do
    @creds_file = 'test_yaml_file.yml'
    @credentials = CredentialsProvider.new @creds_file
  end

  it 'should have no credentials at first' do
    File.delete(@creds_file) if File.file?(@creds_file)
    expect(@credentials.get_password 'System').to eql('')
  end

  it 'should only have credentials for systems that have been set' do
    File.delete(@creds_file) if File.file?(@creds_file)
    test_credentials = 'user:password'
    @credentials.set_password('System', test_credentials)

    expect(@credentials.get_password 'System').to eql(test_credentials.split(':'))
    expect{@credentials.get_password 'System-2'}.to raise_error
  end

  it 'should have credentials for multiple systems' do
    File.delete(@creds_file) if File.file?(@creds_file)

    test_credentials = 'user:password'
    @credentials.set_password('System', test_credentials)

    test_credentials2 = 'user2:password2'
    @credentials.set_password('System-2', test_credentials2)

    expect(@credentials.get_password 'System').to eql(test_credentials.split(':'))
    expect(@credentials.get_password 'System-2').to eql(test_credentials2.split(':'))
  end

  after :all do
    File.delete(@creds_file) if File.file?(@creds_file)
  end
end