require 'logger'
require 'json'
require_relative 'group_detailer_base'

class ReleaseLookup < GroupDetailerBase
  def initialize(detail_query = RallyReleaseQuery.new)
    super(detail_query, 'Release')
  end
end