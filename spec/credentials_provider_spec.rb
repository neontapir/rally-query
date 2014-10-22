require 'rspec'

require_relative '../lib/credentials_provider'

describe 'Credentials provider' do
  before :all do
    @creds_file = 'test_yaml_file.yml'
    @credentials = CredentialsProvider.new @creds_file
  end

  it 'should have no credentials at first' do
    File.delete(@creds_file) if File.file?(@creds_file)
    expect(@credentials.get).to eql('')
  end

  it 'should provide create credentials' do
    test_credentials = 'user:password'
    @credentials.set(test_credentials)
    expect(File.file?(@creds_file)).to be_truthy

    data = File.read(@creds_file)
    expect(data).not_to be_nil

    expect(@credentials.get).to eql(test_credentials.split(':'))
  end

  after :all do
    File.delete(@creds_file) if File.file?(@creds_file)
  end
end