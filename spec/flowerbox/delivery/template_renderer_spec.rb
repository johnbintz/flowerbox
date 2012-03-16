require 'spec_helper'

describe Flowerbox::Delivery::TemplateRenderer do
  let(:template_renderer) { described_class.new(:template => template, :files => files) }
  let(:template) { 'template' }
  let(:files) { 'files' }

  let(:rendered_template) { 'rendered template' }
  let(:erb_template) { "#{rendered_template} <%= resource_tags %>" }

  describe '#render' do
    subject { template_renderer.render }

    let(:rendered_files) { 'with files' }
    let(:result) { "#{rendered_template} #{rendered_files}" }

    before do
      template_renderer.expects(:resource_tags).returns(rendered_files)
      template_renderer.expects(:template).returns(erb_template)
    end

    it { should == result }
  end

  describe '#template' do
    include FakeFS::SpecHelpers

    before do
      File.open(template, 'wb') { |fh| fh.print erb_template }
    end

    subject { template_renderer.template }

    it { should == erb_template }
  end

  describe '#resource_tags' do
    subject { template_renderer.resource_tags }

    context 'success' do
      let(:files) { [ js, css ] }
      let(:js) { 'file.js' }
      let(:css) { 'file.css' }

      it { should == [
        %{<script src="#{js}" type="text/javascript"></script>},
        %{<link rel="stylesheet" href="#{css}" type="text/css" />}
      ].join }
    end

    context 'failure' do
      let(:files) { [ 'what.ever' ] }

      it 'should raise error' do
        expect { subject }.to raise_error(Flowerbox::Delivery::TemplateRenderer::FileTypeError)
      end
    end
  end
end
