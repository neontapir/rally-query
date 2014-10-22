require 'logger'
require 'json'
require_relative 'group_detailer_base'
require_relative 'rally_release_query'

class ReleaseDetailer < GroupDetailerBase
  def initialize(detail_query = RallyReleaseQuery.new)
    super(detail_query, 'Release')
  end
end