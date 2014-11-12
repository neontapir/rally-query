require 'mustache'
require_relative '../rally_work_item_factory'

class WorkItemBaseFormat < Mustache
  attr_accessor :work_items

  def stories
    raise 'Must implement in descendant'
  end

  def format_date(value)
    if value != 'N/A'
      Time.parse(value.to_s).localtime.strftime '%F'
    else
      'N/A'
    end
  end

  def format_number(value)
    '%5.3f' % value
  end
end
