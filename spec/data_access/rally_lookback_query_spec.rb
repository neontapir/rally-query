require_relative '../spec_helper'
require_relative '../../lib/configuration_factory'
require_relative '../../lib/data_access/rally_lookback_query'

describe 'Rally lookback query' do
  before :all do
    ConfigurationFactory.ensure
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

  context 'kanban field name' do
    it 'should get the right one for each project' do
      test_cases = {
          'EGX - Backend' => 'c_EGXKanbanState',
          'EGX - GUI' => 'c_EGXGUIKanbanState',
      }
      test_cases.keys.each do |testCase|
        expect(@query.get_kanban_field_name(testCase)).to eq(test_cases[testCase])
      end
    end

    it 'should raise an error if project is unknown' do
      expect(@query.get_kanban_field_name 'xyzzy').to be_nil
    end
  end
end
