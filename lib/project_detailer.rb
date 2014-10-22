require 'logger'
require 'json'
require_relative 'group_detailer_base'

class ProjectDetailer < GroupDetailerBase
  def initialize(detail_query = RallyProjectQuery.new)
    super(detail_query, 'Project')
  end
end
