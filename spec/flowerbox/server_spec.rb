require 'spec_helper'
require 'socket'
require 'thread'

require 'flowerbox/server'

describe Flowerbox::Server do
  let(:server) { described_class.new(runner, options) }
  let(:options) { nil }
  let(:runner) { nil }

  subject { server }

  describe '#initialize' do
    let(:options) { { :port => port, :interface => interface } }
    let(:port) { 'port' }
    let(:interface) { 'interface' }

    its(:port) { should == port }
    its(:interface) { should == interface }
  end

  describe '#app' do
    subject { server.app }

    context 'no app defined' do
      before do
        server.stubs(:options).returns({})
      end

      it 'should raise an error' do
        expect { server.app }.to raise_error(Flowerbox::Server::MissingRackApp)
      end
    end

    context 'app defined' do
      let(:app) { 'app' }

      before do
        server.stubs(:options).returns(:app => app)
      end

      it { should == app }
    end
  end

  describe '#start' do
    let(:port) { 12345 }
    let(:interface) { '127.0.0.1' }

    before do
      server.stubs(:port).returns(port)
      server.stubs(:interface).returns(interface)
      server.stubs(:app).returns(lambda { |env| [ 200, {}, [] ] })
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

        server.stubs(:random_port).returns(initial, initial + 2)

        count = 10
        while count > 0
          begin
            TCPSocket.new(interface, initial)
            break
          rescue Errno::ECONNREFUSED
            count -= 1
            sleep 0.1
          end
        end
      end

      it { should == initial + 2 }

      after do
        @server.kill
      end
    end
  end
end

