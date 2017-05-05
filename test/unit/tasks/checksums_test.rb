require 'test_helper'

class ChecksumsRakeTest < ActiveSupport::TestCase
  context "checksums:update rake task" do
    setup do
      Rake::Task["checksums:update"].reenable
      SmartAnswer::FlowRegistry.any_instance.stubs(:available_flows).returns(['foo', 'bar'])
    end

    context "with arguments foo" do
      should "call ChecksumGenerator.update" do
        ChecksumGenerator.expects(:update).once

        capture_io do
          Rake::Task["checksums:update"].invoke("foo")
        end
      end
    end

    context "when no flows are specified" do
      should "call ChecksumGenerator with all flows" do
        ChecksumGenerator.expects(:update).twice

        capture_io do
          Rake::Task["checksums:update"].invoke
        end
      end
    end

    context "when an unknown flow is specified" do
      should "raise an exception" do
        exception = assert_raises RuntimeError do
          Rake::Task["checksums:update"].invoke('baz', 'cat')
        end

        assert_equal exception.message, "The following flows could not be found: baz, cat"
      end
    end
  end

  context "checksums:add_files rake task" do
    setup do
      Rake::Task["checksums:add_files"].reenable
    end

    context "when the flow name is specified" do
      should "call ChecksumGenerator.add_files" do
        ChecksumGenerator.expects(:add_files).once

        capture_io do
          Rake::Task["checksums:add_files"].invoke('foo')
        end
      end
    end

    context "when the flow name is omitted" do
      should "raise an exception" do
        exception = assert_raises RuntimeError do
          Rake::Task["checksums:add_files"].invoke
        end

        assert_equal exception.message, "The flow name must be specified"
      end
    end
  end
end
