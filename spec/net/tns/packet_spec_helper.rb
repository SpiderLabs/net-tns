require "tns_spec_helper"

shared_examples_for "a TNS packet class" do
  it "should instantiate with no arguments without any errors" do
    expect{ subject.inspect }.not_to raise_error
  end

  it "should have the correct type number" do
    subject.update_header()
    expect(subject.header.packet_type).to eql(tns_type)
  end
end

shared_examples_for "a TNS packet that can be properly created and sent" do
  it "should correctly compose a packet" do
    pending("Expected field values") if field_values.empty?
    field_values.each do |fieldname, value|
      accessor = (fieldname.to_s + "=").to_sym
      subject.__send__(accessor, value)
    end

    expect(subject).to eql_binary_string( raw_packet )
  end
end

shared_examples_for "a TNS packet that can be properly received and parsed" do
  let(:socket) { SpecHelpers::FakeSocket.new() }

  before :each do
    socket._queue_response(raw_packet) if raw_packet
  end

  it "should correctly read a packet" do
    pending("Sample Data") unless socket._has_unread_data?

    packet = nil
    expect {packet = Net::TNS::Packet.from_socket(socket)}.not_to raise_error
    expect(packet).to be_a(subject.class)

    expect(socket._has_unread_data?).to be false
  end

  it "should correctly parse a packet" do
    pending("Sample Data") unless socket._has_unread_data?

    packet = Net::TNS::Packet.from_socket(socket)
    expect(packet.to_binary_s).to eql(raw_packet)

    field_values.each do |fieldname,value|
      expect(packet.__send__(fieldname)).to eql(value)
    end
  end
end
