require 'business_time'
require_relative 'spec_helper'
require_relative '../lib/configuration_factory'
require_relative '../lib/data_access/rally_work_item_detailer'
require_relative '../lib/rally_work_item_factory'
require_relative '../lib/work_item_export_extensions'

include WorkItemExportExtensions

describe 'Work item DE7756' do  
  let(:work_item) do
    ConfigurationFactory.ensure
    detailer = RallyWorkItemDetailer.new
    id = 'DE7756'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      results = detailer.get_data id
      @item = RallyWorkItemFactory.create(results)
    end
    @item
  end

  it 'should have a non-negative adjusted ready hours calculation' do
    expect(work_item.creation_date).not_to be_nil, 'nil creation date'
    expect(work_item.ready_date).not_to be_nil, 'nil ready date'
    expect(work_item.creation_date).to be < work_item.ready_date, 'ready date after creation date'
    expect(work_item.design_date).to be_nil, 'nil design date'

    value = work_item.ready_date.business_time_until(work_item.design_date || Time.new(work_item.creation_date) || Time.now).abs / 1.hour
    expect(value.to_f).to be >= 0.0, 'negative adjusted ready hours'
  end

  it 'should have a non-negative adjusted ready hours value' do
    expect(work_item.adjusted_ready_hours.to_f).to be >= 0.0
  end

  it 'should have a non-negative adjusted design hours value' do
    expect(work_item.adjusted_design_hours.to_f).to be >= 0.0
  end

  it 'should have a non-negative adjusted development hours value' do
    expect(work_item.adjusted_development_hours.to_f).to be >= 0.0
  end

  it 'should have a non-negative adjusted validation hours value' do
    expect(work_item.adjusted_validation_hours.to_f).to be >= 0.0
  end

  it 'should have a non-negative adjusted cycle time value' do
    expect(work_item.adjusted_cycle_time.to_f).to be >= 0.0
  end
end