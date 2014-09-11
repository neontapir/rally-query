require 'rspec'
require 'spec_helper'
require 'vcr'
require_relative '../rally_lookback_query'
require_relative '../vcr_setup'

describe 'Rally lookback query object' do
  before :all do
    VCR.configure do |c|
      c.cassette_library_dir = 'vcr_cassettes'
      c.hook_into :webmock
    end
  end

  before :each do
    @query = RallyLookbackQuery.new
  end

  it "should connect to Rally's lookback API" do
    id = 'US53364'
    project = 'EGX - Backend'
    VCR.use_cassette("#{id}-lookback", record: :new_episodes, match_requests_on: [:method, :uri, :body]) do
      lookback = @query.get_raw_lookback id, project
      expect(lookback.code).to eq(200)
    end
  end

  it 'should get the right kanban field for each project' do
    test_cases = {
        'EGX - Backend' => 'c_EGXKanbanState',
        'EGX - GUI' => 'c_EGXGUIKanbanState',
    }
    test_cases.keys.each do |testCase|
      expect(@query.get_kanban_field_name(testCase)).to eq(test_cases[testCase])
    end
  end

  it 'should raise an error if project is unknown' do
    expect { @query.get_kanban_field_name 'xyzzy' }.to raise_error
  end
end
