require "test_helper"

class ContentBlockDetectorTest < ActiveSupport::TestCase
  setup do
    @flow = mock("flow")
    @flow.stubs(:name).returns("example")
    @flow_class = mock("flow_class")
    @flow_class.stubs(:to_s).returns("ExampleFlow")
    @flow.stubs(:class).returns(@flow_class)

    @flow_file = "/path/to/flow.rb"
    @template_file = "/path/to/template.erb"
    @calculator_file = "/path/to/calculator.rb"

    @detector = ContentBlockDetector.new(@flow)
  end

  context "#flow_filename" do
    should "return the filename for the flow" do
      Object.expects(:const_source_location).with(@flow_class.to_s).returns([@flow_file])

      assert_equal @flow_file, @detector.flow_filename
    end
  end

  context "#calculators" do
    should "return the filename for the template" do
      flow_content = "FLOW CONTENT"
      calculator = stub("calculator", constantize: "calculator_constantized")

      @detector.stubs(:flow_filename).returns(@flow_file)
      File.expects(:read).with(@flow_file).returns(flow_content)
      flow_content.expects(:scan)
                  .with(ContentBlockDetector::CALCULATOR_PATTERN)
                  .returns([calculator])

      assert_equal [calculator.constantize], @detector.calculators
    end
  end

  context "#calculator_filenames" do
    should "return the filename for the calculators" do
      calculator = stub("calculator")

      @detector.stubs(:calculators).returns([calculator])
      Object.stubs(:const_source_location)
            .with(calculator.to_s)
            .returns([@calculator_file])

      assert_equal [@calculator_file], @detector.calculator_filenames
    end
  end

  context "#template_filenames" do
    should "return the filename for the templates" do
      glob = File.join("app", "flows", @flow.name.underscore + "_flow", "**", "*.erb")
      Dir.expects(:glob).with(glob)
         .returns([@template_file])

      assert_equal [@template_file], @detector.template_filenames
    end
  end

  context "#flow_content" do
    should "return the content for the flow's files" do
      @detector.stubs(:flow_filename).returns(@flow_file)
      @detector.stubs(:calculator_filenames).returns(@calculator_file)
      @detector.stubs(:template_filenames).returns(@template_file)

      flow_content = "FLOW CONTENT"
      calculator_content = "CALCULATOR CONTENT"
      template_content = "TEMPLATE CONTENT"

      File.expects(:read).with(@flow_file).returns(flow_content)
      File.expects(:read).with(@calculator_file).returns(calculator_content)
      File.expects(:read).with(@template_file).returns(template_content)

      expected_content = [flow_content, calculator_content, template_content].join

      assert_equal expected_content, @detector.flow_content
    end
  end

  context "#content_blocks" do
    should "return unique content blocks from flow content" do
      flow_content = "FLOW CONTENT"

      @detector.stubs(:flow_content).returns(flow_content)

      reference = stub("reference", embed_code: "EMBED CODE")
      content_block = stub("content_block")

      ContentBlockTools::ContentBlockReference.stubs(:find_all_in_document)
                                              .with(flow_content)
                                              .returns([reference])

      ContentBlockTools::ContentBlock.stubs(:from_embed_code)
                                     .with(reference.embed_code)
                                     .returns(content_block)

      assert_equal [content_block], @detector.content_blocks
    end
  end
end
