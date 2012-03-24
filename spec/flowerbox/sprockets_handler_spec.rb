require 'spec_helper'
require 'flowerbox/sprockets_handler'

describe Flowerbox::SprocketsHandler do
  let(:sprockets_handler) { described_class.new(options) }
  let(:options) { { :asset_paths => asset_paths } }
  let(:asset_paths) { [ File.expand_path('asset path') ] }

  describe '#add' do
    let(:asset) { 'asset' }
    let(:dependent_asset) { 'dependent' }

    let(:pathname_path) { 'pathname path' }
    let(:files) { stub }

    before do
      sprockets_handler.expects(:assets_for).with(asset).returns([ dependent_asset ])
      sprockets_handler.stubs(:files).returns(files)
      files.expects(:add).with(dependent_asset)
    end

    it 'should add the asset to the list of ones to work with' do
      sprockets_handler.add(asset)
    end
  end

  describe '#environment' do
    let(:cache) { stub }

    before do
      sprockets_handler.stubs(:cache).returns(cache)
      sprockets_handler.stubs(:default_asset_paths).returns([])
    end

    subject { sprockets_handler.environment }

    it { should be_a_kind_of(Sprockets::Environment) }
  end

  describe '#default_asset_paths' do
    let(:gem) { 'gem' }
    let(:asset) { 'asset' }

    before do
      described_class.stubs(:gem_asset_paths).returns([ gem ])
      sprockets_handler.stubs(:options).returns(:asset_paths => [ asset ])
    end

    subject { sprockets_handler.default_asset_paths }

    it { should == [ gem, asset ] }
  end

  describe '#assets_for' do
    subject { sprockets_handler.assets_for(asset) }

    let(:asset) { 'asset' }
    let(:found_asset) { 'found asset' }
    let(:other_asset) { 'other asset' }

    before do
      sprockets_handler.stubs(:find_asset).returns(found_asset)
      found_asset.stubs(:to_a).returns(other_asset)
    end

    it { should == other_asset }
  end

  describe '#logical_path_for' do
    subject { sprockets_handler.logical_path_for(asset) }

    let(:path) { 'path' }
    let(:result) { 'result' }

    let(:asset) { stub(:pathname => Pathname("#{path}/#{result}")) }

    before do
      sprockets_handler.stubs(:paths).returns(paths)
    end

    context 'found' do
      let(:paths) { [ path ] }

      it { should == result }
    end

    context 'not found' do
      let(:paths) { [] }

      it 'should raise an exception' do
        expect { subject }.to raise_error(Flowerbox::SprocketsHandler::LogicalPathNotFoundError)
      end
    end
  end
end

