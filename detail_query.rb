require 'rest-client'
require 'open-uri'
require 'logger'

require_relative 'query'

class DetailQuery < Query
  WEBSERVICE_ROOT = 'https://rally1.rallydev.com/slm/webservice/v2.0'

  def webservice_root
    WEBSERVICE_ROOT
  end

  def get_raw_details(work_item_id)
    story = canonize work_item_id
    item_type = item_type_identifier story
    make_get_rest_call "#{WEBSERVICE_ROOT}/#{item_type}?query=(FormattedID = #{story})&fetch=true&workspace=#{workspace_url}"
  end

  def get_story_details(object_id)
    item_type = item_type_identifier 'US'
    get_details_by_id(item_type, object_id)
  end

  def get_defect_details(object_id)
    item_type = item_type_identifier 'DE'
    get_details_by_id(item_type, object_id)
  end

  def get_raw_release(release_id)
    make_get_rest_call "#{WEBSERVICE_ROOT}/releases/#{release_id}?workspace=#{workspace_url}"
  end

  def get_raw_user(user_id)
    make_get_rest_call "#{WEBSERVICE_ROOT}/users/#{user_id}?workspace=#{workspace_url}"
  end

  def get_raw_project(project_id)
    make_get_rest_call "#{WEBSERVICE_ROOT}/project/#{project_id}?workspace=#{workspace_url}"
  end

  def get_raw_feature(feature_id)
    make_get_rest_call "#{WEBSERVICE_ROOT}/portfolioitem/feature/#{feature_id}?workspace=#{workspace_url}"
  end

  def get_project_children(project_id)
    make_get_rest_call "#{WEBSERVICE_ROOT}/project/#{project_id}/children?workspace=#{workspace_url}"
  end

  def get_details_by_id(item_type, object_id)
    make_get_rest_call "#{WEBSERVICE_ROOT}/#{item_type}/#{object_id}?fetch=true&workspace=#{workspace_url}"
  end
end
