require 'mustache'
require_relative 'work_item_base_format'
require_relative 'work_item'

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
