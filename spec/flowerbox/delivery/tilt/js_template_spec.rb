require 'spec_helper'

describe Flowerbox::Delivery::Tilt::JSTemplate do
  let(:js_template) { described_class.new { '' } }

  describe '#evaluate' do
    subject { js_template.evaluate(Object.new, {}) }

    before do
      js_template.stubs(:file).returns(file)
    end

    context '.js' do
      let(:file) { 'file.js' }

      it { should == file }
    end

    context 'other extension' do
      let(:file) { 'file.coffee' }
      let(:temp_file) { 'temp file' }

      before do
        js_template.expects(:save).returns(temp_file)
      end

      it { should == temp_file }
    end
  end

  describe '#save' do
    include FakeFS::SpecHelpers

    let(:temp_file) { 'dir/temp file' }
    let(:data) { 'data' }

    before do
      js_template.stubs(:temp_file).returns(temp_file)
      js_template.stubs(:data).returns(data)
    end

    it 'should save the file to disk and return the temp path' do
      js_template.save.should == temp_file

      File.read(temp_file).should == data
    end
  end

  describe '#temp_file' do
    subject { js_template.temp_file }

    let(:filename) { "#{root_filename}.ext" }
    let(:root_filename) { "dir/file.js" }

    before do
      js_template.stubs(:file).returns(filename)
    end

    it { should == File.join(Dir.pwd, '.tmp/sprockets', root_filename) }
  end
end

