require 'mustache'
require_relative 'work_item_base_format'
require_relative '../rally_work_item_factory'

class WorkItemFeatureFormat < WorkItemBaseFormat
  attr_accessor :work_items

  def stories
    @work_items.map do |w|
      {
          id: w
      }
    end
  end
end
