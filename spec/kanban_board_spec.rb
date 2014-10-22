require 'rspec'
require_relative('../lib/kanban_board')

class KanbanBoardSpec
  describe 'construction' do
    it 'should place normal stories on the Backend board' do
      expect(KanbanBoard.new('EGX - Backend', nil).to_str).to eq(KanbanBoard::BACKEND)
    end

    it 'should place R&D stories on the Backend board' do
      expect(KanbanBoard.new('EGX - R&D', nil).to_str).to eq(KanbanBoard::BACKEND)
    end

    it 'should place GUI stories correctly' do
      expect(KanbanBoard.new('EGX - GUI', nil).to_str).to eq(KanbanBoard::GUI)
    end

    it 'should place Rules stories correctly' do
      expect(KanbanBoard.new('EGX - Backend', 'EGX-Rules').to_str).to eq(KanbanBoard::RULES)
    end

    it 'should place Adapters stories correctly' do
      expect(KanbanBoard.new('EGX - Backend', 'EGX-Adapters').to_str).to eq(KanbanBoard::ADAPTERS)
    end
  end
end