require_relative 'spec_helper'
require_relative '../lib/class_of_service'

class ClassOfServiceSpec
  describe 'Class of service' do
    it 'should identify standard stories' do
      expect(ClassOfService.new('US12345', 'foo').to_str).to eq('Standard')
    end

    it 'should identify spikes' do
      expect(ClassOfService.new('US12345', 'Spike: foo').to_str).to eq('Spike')
    end

    it 'should identify defects' do
      expect(ClassOfService.new('DE9876', 'foo').to_str).to eq('Defect')
    end

    it 'should identify defects by description' do
      expect(ClassOfService.new('US12345', 'Defect: foo').to_str).to eq('Defect')
    end
  end
end