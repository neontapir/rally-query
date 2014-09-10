require 'rspec'

class ClassOfServiceSpec
  describe 'construction' do
    it 'should create standard stories' do
      expect(ClassOfService.new('US12345', 'foo').to_str).to eq('Standard')
    end

    it 'should create spikes' do
      expect(ClassOfService.new('US12345', 'Spike: foo').to_str).to eq('Spike')
    end

    it 'should create defects' do
      expect(ClassOfService.new('DE9876', 'foo').to_str).to eq('Defect')
    end

    it 'should create defects by description' do
      expect(ClassOfService.new('US12345', 'Defect: foo').to_str).to eq('Defect')
    end
  end
end