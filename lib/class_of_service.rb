class ClassOfService
  attr_reader :service_class

  def initialize(id, name)
    @service_class = case
                       when id =~ /^DE/ then
                         'Defect'
                       when name =~ /\bDefect\b/i then
                         'Defect'
                       when name =~ /\bSpike\b/i then
                         'Spike'
                       else
                         'Standard'
                     end
  end

  def to_s
    @service_class
  end

  def to_str
    to_s
  end
end