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
end
