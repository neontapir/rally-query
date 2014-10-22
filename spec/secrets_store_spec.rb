require 'rspec'

require_relative '../lib/secrets_store'

describe 'Secrets store' do
  before(:each) do
    secrets_file = "test_yaml_file.yml"
    @credentials = SecretsStore.new secrets_file
    File.delete(@credentials.filename) if File.file?(@credentials.filename)
  end

  PASSWORD_KEY = 'password'

  it 'should have no credentials at first' do
    expect(@credentials.get PASSWORD_KEY, 'System').to eql('')
  end

  it 'should only have credentials for systems that have been set' do
    test_credentials = 'user:password'
    @credentials.set(PASSWORD_KEY, test_credentials, 'System')

    expect(@credentials.get PASSWORD_KEY, 'System').to eql(test_credentials.split(':'))
    expect {@credentials.get PASSWORD_KEY, 'System-2'}.to raise_error
  end

  it 'should have credentials for multiple systems' do
    test_credentials = 'user:password'
    @credentials.set(PASSWORD_KEY, test_credentials, 'System')

    test_credentials2 = 'user2:password2'
    @credentials.set(PASSWORD_KEY, test_credentials2, 'System-2')

    expect(@credentials.get PASSWORD_KEY, 'System').to eql(test_credentials.split(':'))
    expect(@credentials.get PASSWORD_KEY, 'System-2').to eql(test_credentials2.split(':'))
  end

  after(:each) do
    File.delete(@credentials.filename) if File.file?(@credentials.filename)
  end
end