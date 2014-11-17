class JiraWorkItemFactory
  def self.create(raw_data)
    create_item raw_data
  end

  private

  def self.create_item(raw_data)
    result = WorkItem.new
    result
  end
end