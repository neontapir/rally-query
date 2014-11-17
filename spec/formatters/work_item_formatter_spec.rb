require_relative '../spec_helper'
require_relative '../capture'

require_relative '../../lib/configuration_factory'
require_relative '../../lib/data_access/rally_work_item_lookup'
require_relative '../../lib/formatters/work_item_export_format'
require_relative '../../lib/formatters/work_item_formatter'
require_relative '../../lib/rally_work_item_factory'

describe 'Work item formatter' do
  before :all do
    ConfigurationFactory.ensure
    @factory = RallyWorkItemFactory.new
  end

  context 'configuration' do
    it 'should get the right formatter class' do
      formatter = WorkItemFormatter.new nil
      expect(formatter.formatter_class).to eq(WorkItemScreenFormat)
    end
  end

  context 'with screen format' do
    before :all do
      work_item_detailer = RallyWorkItemLookup.new
      id = 'US53364'
      VCR.use_cassette("#{id}-details", :record => :new_episodes) do
        @results = work_item_detailer.get_data id
      end

      work_item = @factory.create(@results)
      # puts "Work item story changes: #{work_item.state_changes}"

      @work_item_formatter = WorkItemFormatter.new(work_item)
      c = Capture.capture do
        @work_item_formatter.dump
      end
      @output = c.stdout
    end

    it 'should have the story ID' do
      expect(@output).to match(/US53364 -- DREV: Validate 2A Traffic/)
      expect(@output).to match(/Project: EGX - R&D/)
      expect(@output).to match(/Release: INSX BETA/)
    end
  end

  context 'with export format' do
    before :all do
      @lookup = RallyWorkItemLookup.new
    end

    it 'with backend story should have the expected output at time of cassette capture' do
      id = 'US53364'
      VCR.use_cassette("#{id}-details", :record => :new_episodes) do
        @results = @lookup.get_data id
        work_item = @factory.create(@results)

        export_format = WorkItemExportFormat.new
        export_format.show_header = true
        formatter = WorkItemFormatter.new(work_item, export_format)
        c = Capture.capture do
          formatter.dump
        end

        csv = CSV.new(c.stdout, headers: true, header_converters: :symbol, col_sep: '|')
        result = csv.to_a.map { |row| row.to_hash }.first

        expect(result[:id]).to eq(id)
        expect(result[:kanban_board]).to eq('Backend')
        expect(result[:keywords]).to match(/DREV/)
        expect(result[:class_of_service]).to eq('Standard')
        expect(result[:rally_create]).to eq('2014-06-06')
        expect(result[:rejected]).to be_nil
      end
    end

    it 'with GUI story should have the expected output at time of cassette capture' do
      # expected = "'id','kanban_board','release','keywords','class_of_service','dev_lead','qa_lead','made_ready_in_validation','actual_story_points','state','rally_create','ready','design','development','validation','accepted','rejected','violations','user_count','defect_count','blocked_hours','design_hours','development_hours','ready_hours','validation_hours'\n'US52586','GUI','INSX BETA','Organization,Certificates','Standard','Alex Alitoits','Nastia Neveykova','Aliaksandra Rabushka','','Validation','2014-05-06','N/A','N/A','2014-06-13','2014-06-17','N/A','N/A','1','9','5','164.178','378.520','23.319','217.794','345.940'\n"
      id = 'US52586'
      VCR.use_cassette("#{id}-details", :record => :new_episodes) do
        VCR.use_cassette("#{id}-lookback", record: :new_episodes, match_requests_on: [:method, :uri, :body]) do
          @results = @lookup.get_data id
        end

        work_item = @factory.create(@results)
        export_format = WorkItemExportFormat.new
        export_format.show_header = true
        formatter = WorkItemFormatter.new(work_item, export_format)
        c = Capture.capture do
          formatter.dump
        end

        csv = CSV.new(c.stdout, headers: true, header_converters: :symbol, col_sep: '|')
        result = csv.to_a.map { |row| row.to_hash }.first

        expect(result).not_to be_nil
        expect(result[:id]).to eq(id)
        expect(result[:kanban_board]).to eq('GUI')
        expect(result[:keywords]).to match(/Organization/) # has two items with embedded comma
        expect(result[:class_of_service]).to eq('Standard')
        expect(result[:rejected]).to be_nil
      end
    end
  end
end
