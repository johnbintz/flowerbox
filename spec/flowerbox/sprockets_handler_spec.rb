require 'spec_helper'

describe Flowerbox::Delivery::SprocketsHandler do
  let(:sprockets_handler) { described_class.new(options) }
  let(:options) { { :asset_paths => asset_paths } }
  let(:asset_paths) { [ File.expand_path('asset path') ] }

  describe '#add' do
    let(:asset) { 'asset' }
    let(:path) { 'path' }
    let(:paths) { [ path ] }

    let(:pathname_path) { 'pathname path' }

    before do
      sprockets_handler.expects(:paths_for).with(asset).returns(paths)
      sprockets_handler.expects(:path_for_compiled_asset).with(path).returns(pathname_path)
    end

    it 'should add the asset to the list of ones to work with' do
      sprockets_handler.add(asset)

      sprockets_handler.files.should == [ pathname_path ]
    end
  end

  describe '#paths_for' do
    subject { sprockets_handler.paths_for(asset) }

    let(:asset) { 'asset' }
    let(:environment) { stub }
    let(:bundled_asset) { stub(:to_a => [ processed_asset ]) }
    let(:processed_asset) { stub(:pathname => path) }

    let(:path) { 'path' }

    before do
      sprockets_handler.stubs(:environment).returns(environment)
      environment.expects(:find_asset).with(asset).returns(bundled_asset)
    end

    it { should == [ path ] }
  end

  describe '#environment' do
    subject { sprockets_handler.environment }

    it { should be_a_kind_of(Sprockets::Environment) }
    its(:paths) { should == asset_paths }
  end
end

