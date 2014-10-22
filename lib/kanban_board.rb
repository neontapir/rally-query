class KanbanBoard
  attr_reader :board

  GUI = 'GUI'
  RULES = 'Rules'
  ADAPTERS = 'Adapters'
  BACKEND = 'Backend'
  TPM = 'TPM'

  def initialize(project, tags = nil)
    @board = case
               when project =~ /EGX - (GUI|TPM)/ then
                 KanbanBoard.const_get($1.upcase)
               when tags =~ /(Rules|Adapters|TPM)/ then
                 KanbanBoard.const_get($1.upcase)
               else
                 BACKEND
             end
  end

  def to_s
    @board
  end

  def to_str
    to_s
  end
end