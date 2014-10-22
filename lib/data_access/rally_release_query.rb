require 'rest-client'
require 'open-uri'
require 'logger'

require_relative 'group_query'

class RallyReleaseQuery < GroupQuery
  def initialize(group_identifier = 'Release')
    @group_identifier = group_identifier
  end
end