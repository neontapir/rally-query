require_relative('logging_provider')

class WorkItemState
  extend LoggingProvider

  # weight reflects the order of Kanban states
  attr_reader :state, :weight

  def self.ready
    new(:ready, 1)
  end

  def self.design
    new(:design, 2)
  end

  def self.development
    new(:development, 3)
  end

  def self.validation
    new(:validation, 4);
  end

  def self.accepted
    new(:accepted, 5)
  end

  def self.rejected
    new(:rejected, -100) # any negative number would work
  end

  def self.rally_create
    new(:rally_create, 0)
  end

  def self.none
    new(:none, 0)
  end

  def self.statuses
    [ready, design, development, validation, accepted, rejected]
  end

  def self.find_by_name(name)
    case name
      when 'Ready', 'Requirements', 'Grooming' then
        self.ready
      when 'Design', 'Wireframes', 'Contracts' then
        self.design
      when 'Development', 'Proof of Concept', 'Production Ready', 'Code Review', 'Merge' then
        self.development
      when 'Validation', 'Release & Merge', 'Deployment' then
        self.validation
      when 'Accepted' then
        self.accepted
      when 'Rejected' then
        self.rejected
      else
        log.debug "Unrecognized Kanban state #{name}"
        self.none
    end
  end

  def initialize (state, weight)
    @state = state
    @weight = weight
  end

  def to_s
    x = @state.to_s
    x.gsub!(/_/, ' ')
    x.split(' ').map { |word| word.capitalize }.join(' ')
  end

  def to_i
    @weight
  end

  def ==(o)
    o.class == self.class && o.state == @state && o.weight == @weight
  end

  alias_method :eql?, :==
end