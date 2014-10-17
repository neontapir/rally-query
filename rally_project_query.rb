require File.expand_path(File.dirname(__FILE__) + '/group_query.rb')
require 'rest-client'
require 'open-uri'
require 'logger'

require_relative 'query'

class RallyProjectQuery < GroupQuery
  def initialize(group_identifier_name = 'Project')
    @group_identifier = group_identifier_name
  end
end
