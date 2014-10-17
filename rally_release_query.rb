require File.expand_path(File.dirname(__FILE__) + '/group_query.rb')
require 'rest-client'
require 'open-uri'
require 'logger'
require_relative 'query'

class RallyReleaseQuery < GroupQuery
  def initialize(group_identifier = 'Release')
    @group_identifier = group_identifier
  end
end