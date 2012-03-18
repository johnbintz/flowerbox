require 'spec_helper'

describe Flowerbox::Delivery::UniqueAssetList do
  let(:unique_asset_list) { described_class.new }

  describe "#add" do
    let(:first) { Pathname.new('one') }
    let(:second) { Pathname.new('one') }
    let(:third) { Pathname.new('two') }

    it 'should not add assets already added' do
      unique_asset_list.add(first)
      unique_asset_list.add([ second, third ])

      unique_asset_list.should == [ first, third ]
    end
  end
end
