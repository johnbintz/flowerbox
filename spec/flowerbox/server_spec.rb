require 'spec_helper'
require 'socket'
require 'thread'

describe Flowerbox::Delivery::Server do
  let(:server) { described_class.new(options) }
  let(:options) { nil }

  subject { server }

  describe '#initialize' do
    let(:options) { { :port => port, :interface => interface } }
    let(:port) { 'port' }
    let(:interface) { 'interface' }

    its(:port) { should == port }
    its(:interface) { should == interface }
  end

  describe '#start' do
    let(:port) { 12345 }
    let(:interface) { '127.0.0.1' }

    before do
      server.stubs(:port).returns(port)
      server.stubs(:interface).returns(interface)
    end

    it 'should start a Rack server' do
      server.start

      TCPSocket.new(server.interface, server.port)
    end
  end

  describe '#interface' do
    subject { server.interface }

    it { should == '0.0.0.0' }
  end

  describe '#port' do
    let(:interface) { '127.0.0.1' }
    let(:base) { 25000 }
    let(:initial) { base + @offset }

    before do
      server.stubs(:interface).returns(interface)

      @offset = 0
      ok = true

      begin
        [ 0, 1 ].each do |index|
          begin
            TCPSocket.new(interface, base + @offset + index)
            @offset += 1
            ok = false
          rescue Errno::ECONNREFUSED => e
          end
        end
      end while !ok
    end

    subject { server.port }

    context 'no running service' do
      before do
        Kernel.stubs(:rand).returns(@offset)
      end

      it { should == initial }
    end

    context 'running service' do
      before do
        @server = Thread.new do
          TCPServer.new(interface, initial)
        end

        server.stubs(:random_port).returns(initial, initial + 1)

        while true
          begin
            TCPSocket.new(interface, initial)
            break
          rescue Errno::ECONNREFUSED
          end
        end
      end

      it { should == initial + 1 }

      after do
        @server.kill
      end
    end
  end
end

