require 'ostruct'
require 'csv'
require 'business_time'

describe 'Just learning Ruby' do
  it 'should convert an array of objects into a hash' do
    expected = {
        'US12345' => 'US12345',
        'DE9876' => 'DE9876',
        '23456' => 'US23456',
        'xyzzy' => nil,
    }
    input = [
        {name: 'US12345', value: 'US12345'},
        {name: 'DE9876', value: 'DE9876'},
        {name: '23456', value: 'US23456'},
        {name: 'xyzzy', value: nil},
    ]
    actual = {}
    input.each do |i|
      o = OpenStruct.new i
      actual[o.name] = o.value
    end
    expect(actual).to be_eql(expected)
  end

  it 'should convert export string to hash' do
    input = "'id','name','value'\n'1','Fred','42'"
    #expected = {'id' => '1', 'name' => 'Fred', 'value' => '42'}

    # actual = {}

    csv = CSV.new(input.gsub!("'", ''), headers: true)
    actual = csv.to_a.map { |row| row.to_hash }.first

    expect(actual).to include('id' => '1')
    expect(actual['id']).to eq('1')
  end

  # it 'should handle business time in hours' do
  #   ticket_reported = Time.parse('February 3, 2012, 10:40 am')
  #   ticket_resolved = Time.parse('February 4, 2012, 10:40 am')
  #   # duration = ticket_reported.business_time_until(ticket_resolved)
  #   # expect(duration / 3600.0).to eq(0)
  # end
end
