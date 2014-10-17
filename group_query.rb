require File.expand_path(File.dirname(__FILE__) + '/query.rb')

class GroupQuery < Query
  attr_accessor :group_identifier
  WEBSERVICE_ROOT = 'https://rally1.rallydev.com/slm/webservice/v2.0'

  def initialize(group_identifier = 'unknown')
    @group_identifier = group_identifier
  end

  def get_raw_defect_list(project_name)
    item_type = item_type_identifier 'DE'
    get_list(project_name, item_type)
  end

  def get_raw_story_list_with_portfolio_items(project_name)
    item_type = item_type_identifier 'US'
    get_list_with_portfolio_items(project_name, item_type)
  end

  def get_raw_story_list(project_name)
    item_type = item_type_identifier 'US'
    get_list(project_name, item_type)
  end

  def webservice_root
    WEBSERVICE_ROOT
  end

  private

  def get_list_with_portfolio_items(group_item_name, item_type)
    query = "#{WEBSERVICE_ROOT}/#{item_type}?workspace=#{workspace_url}&query=(#{@group_identifier}.Name = \"#{group_item_name}\")&fetch=FormattedID,PortfolioItem"
    make_get_rest_call query
  end

  def get_list(group_item_name, item_type)
    query = "#{WEBSERVICE_ROOT}/#{item_type}?workspace=#{workspace_url}&query=(#{@group_identifier}.Name = \"#{group_item_name}\")&fetch=FormattedID"
    make_get_rest_call query
  end
end
