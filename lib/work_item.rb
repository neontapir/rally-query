require 'configatron'
require 'json'
require 'forwardable'
require_relative 'logging_provider'

class WorkItem
  include LoggingProvider

  extend Forwardable
  def_delegators :@state_changes, :blocked_hours, :state_change_violations, :status_counts, :dev_lead, :qa_lead,
                 :made_ready_in_validation

  attr_accessor :id, :name, :title, :project, :feature, :release, :tags, :state_changes,
                :defect_count, :defects_status, :story_points, :current_state, :kanban_field,
                :creation_date, :schedule_dates

  def keywords
    # note: spaces are escaped in a %w string
    @keyword_items ||= Set.new %w(User Security Party Flows Rules Contactinfo Info IDs Adapters \
       Organization Activity Audit Adapter\ Types Context Compatibility Testing Navigation \
       Relationships IE Errors Certificates SMS S3 Database Infrastructure AWS Prototyping API \
       Broker DREV TPM Jmeter Performance IAM AMI Test Build Smooks Deploy UE Implementation QoS \
       eInvoicing LDAP EB Alerts ETL Activity Framework DocSim Tika Environment Data-Commons \
       Rule\ Type Metrics Data\ Poller)
    keys = @keyword_items.select { |w| /#{w}/i =~ @name }
    keys.join(',')
  end

  def class_of_service
    @class_of_service ||= ClassOfService.new @id, @name
  end

  def kanban_board
    @kanban_board ||= KanbanBoard.new @project
  end

  def users
    @state_changes.map(&:user).uniq.length
  end

  def ready_date
    @state_changes.kanban_state_dates['Ready']
  end

  def design_date
    @state_changes.kanban_state_dates['Design']
  end

  def development_date
    @state_changes.kanban_state_dates['Development']
  end

  def validation_date
    @state_changes.kanban_state_dates['Validation']
  end

  def accepted_date
    @state_changes.kanban_state_dates['Accepted']
  end

  def rejected_date
    @state_changes.kanban_state_dates['Rejected']
  end

  def schedule_requested_date
    @state_changes.schedule_state_dates['Requested']
  end

  def schedule_defined_date
    @state_changes.schedule_state_dates['Defined']
  end

  def schedule_in_progress_date
    @state_changes.schedule_state_dates['In Progress']
  end
end
