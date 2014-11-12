require 'rspec'

require_relative '../query_engine'

describe 'Story query' do
  it 'is not nil' do
    story_query = QueryEngine.new
    expect(story_query).not_to be_nil
  end
end