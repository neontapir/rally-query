require 'logger'
require 'json'
require_relative 'group_detailer_base'

class ProjectLookup < GroupDetailerBase
  def initialize(detail_query = RallyProjectQuery.new)
    super(detail_query, 'Project')
  end
end
