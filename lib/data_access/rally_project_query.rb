require File.expand_path(File.dirname(__FILE__) + '/rally_group_query.rb')
require 'rest-client'
require 'open-uri'
require 'logger'

require_relative 'rally_query'

class RallyProjectQuery < RallyGroupQuery
  def initialize(group_identifier = 'Project')
    @group_identifier = group_identifier
  end
end
