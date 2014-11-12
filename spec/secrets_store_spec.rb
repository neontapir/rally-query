require_relative 'spec_helper'
require_relative '../lib/secrets_store'

describe 'Secrets store' do
  before(:each) do
    secrets_file = "test_yaml_file.yml"
    @credentials = SecretsStore.new secrets_file
    File.delete(@credentials.filename) if File.file?(@credentials.filename)
  end

  it 'should have no credentials at first' do
    expect(@credentials.get_password 'System').to be_nil
  end

  it 'should store multiple items per system' do
    test_credentials = 'user:password'
    @credentials.set_password(test_credentials, 'System')

    test_workspace = '12345'
    @credentials.set('workspace', test_workspace, 'System')

    expect(@credentials.get_password 'System').to eql(test_credentials.split(':'))
    expect(@credentials.get 'workspace', 'System').to eql(test_workspace)
    
    expect {@credentials.get_password 'System-2'}.to raise_error
  end

  it 'should only have credentials for systems that have been set' do
    test_credentials = 'user:password'
    @credentials.set_password( test_credentials, 'System')

    expect(@credentials.get_password 'System').to eql(test_credentials.split(':'))
    expect {@credentials.get_password 'System-2'}.to raise_error
  end

  it 'should have credentials for multiple systems' do
    test_credentials = 'user:password'
    @credentials.set_password( test_credentials, 'System')

    test_credentials2 = 'user2:password2'
    @credentials.set_password( test_credentials2, 'System-2')

    expect(@credentials.get_password 'System').to eql(test_credentials.split(':'))
    expect(@credentials.get_password 'System-2').to eql(test_credentials2.split(':'))
  end

  after(:each) do
    File.delete(@credentials.filename) if File.file?(@credentials.filename)
  end
end