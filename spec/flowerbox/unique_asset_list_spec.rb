require 'spec_helper'
require 'flowerbox/unique_asset_list'

describe Flowerbox::UniqueAssetList do
  let(:unique_asset_list) { described_class.new(sprockets) }
  let(:sprockets) { stub }

  describe "#add" do
    let(:first) { stub(:pathname => Pathname.new('one')) }
    let(:second) { stub(:pathname => Pathname.new('one')) }
    let(:third) { stub(:pathname => Pathname.new('two')) }

    it 'should not add assets already added' do
      unique_asset_list.add(first)
      unique_asset_list.add([ second, third ])

      unique_asset_list.should == [ first, third ]
    end
  end

  describe '#to_json' do
    subject { unique_asset_list.to_json }

    let(:file) { 'file' }
    let(:path) { 'path' }

    before do
      unique_asset_list.replace([ file ])
      sprockets.expects(:logical_path_for).with(file).returns(path)
    end

    it { should == [ path ] }
  end

  describe '#<<' do
    let(:asset) { stub(:pathname => Pathname(path)) }
    let(:path) { 'path' }

    it 'should add the asset and mark it included' do
      unique_asset_list << asset

      unique_asset_list.should == [ asset ]
      unique_asset_list.should be_included(asset)
    end
  end
end

