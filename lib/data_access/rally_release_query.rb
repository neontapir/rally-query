require 'rest-client'
require 'open-uri'
require 'logger'

require_relative 'rally_group_query'

class RallyReleaseQuery < RallyGroupQuery
  def initialize(group_identifier = 'Release')
    @group_identifier = group_identifier
  end
end