require 'spec_helper'
require 'flowerbox/reporter/json'

describe Flowerbox::Reporter::JSON do
  let(:json) { described_class.new }

  describe '#report_numeric_results' do
    let(:results) { 'results' }
    let(:numeric_results_for) { 'numeric results for' }

    before do
      json.expects(:numeric_results_for).with(results).returns(numeric_results_for)
      json.expects(:puts)
    end

    it 'should add numeric results' do
      json.report_numeric_results(results)

      json.output.should == [ [ :results, numeric_results_for ] ]
    end
  end
end
