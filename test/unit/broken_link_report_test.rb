require "test_helper"
require "minitest/autorun"

class BrokenLinkReportTest < ActiveSupport::TestCase
  def path
    # Defaulting path to only radio-sample flow to limit scope of most tests (simpler and faster)
    @path ||= Rails.root.join "test/fixtures/flows/radio_sample_flow"
  end

  def broken_link_report
    @broken_link_report ||= BrokenLinkReport.new(path)
  end

  def folder
    @folder ||= BrokenLinkReport::Folder.new(path)
  end

  def erb_file_path
    File.expand_path("outcomes/hot.erb", path)
  end

  def erb_file_content
    File.read erb_file_path
  end

  def totals
    @totals ||= {
      links: 1,
      ok: 0,
    }
  end

  def status
    @status ||= :broken
  end

  def link
    @link ||= OpenStruct.new(
      status: status,
      uri: "http://example.com/foo/bar",
      problem_summary: "Whoops",
      errors: ["It broke"],
      suggested_fix: "Contact webmaster",
    )
  end

  def links
    @links ||= [link]
  end

  def report
    @report ||= OpenStruct.new(
      totals: OpenStruct.new(totals),
      links: links,
    )
  end

  def mock_link_checker
    OpenStruct.new(report: report)
  end

  context ".for_erb_files_at" do
    should "return the summary report for live flows" do
      @path = Rails.root.join("app/flows")
      LinkChecker.stub :new, mock_link_checker do
        report = BrokenLinkReport.for_erb_files_at(@path)
        assert_equal broken_link_report.summary_report, report
      end
    end
  end

  context "#summary_report" do
    should "include broken link" do
      LinkChecker.stub :new, mock_link_checker do
        assert_includes broken_link_report.summary_report, link.uri
        assert_includes broken_link_report.summary_report, link.problem_summary
        assert_includes broken_link_report.summary_report, link.errors.first
        assert_includes broken_link_report.summary_report, link.suggested_fix
      end
    end

    should "be blank if totals match" do
      @totals = { links: 1, ok: 1 }
      LinkChecker.stub :new, mock_link_checker do
        assert broken_link_report.summary_report.blank?
      end
    end

    should "not include link if status ok" do
      @status = :ok
      LinkChecker.stub :new, mock_link_checker do
        assert_not_includes broken_link_report.summary_report, link.uri
        assert_not_includes broken_link_report.summary_report, link.problem_summary
        assert_not_includes broken_link_report.summary_report, link.errors.first
        assert_not_includes broken_link_report.summary_report, link.suggested_fix
      end
    end
  end

  context "#folders" do
    should "be instances of Folder" do
      assert_kind_of BrokenLinkReport::Folder, broken_link_report.folders.first
    end

    should "contain a folder representing the child folder" do
      assert_includes broken_link_report.folders.map(&:name), "outcomes"
    end

    should "find many folders if path is to smart_answers_flows" do
      @path = Rails.root.join "test/fixtures/flows"
      assert broken_link_report.folders.length > 1
    end

    should "include radio_sample_flow as child if path is to smart_answers_flows" do
      @path = Rails.root.join "test/fixtures/flows"
      assert_includes broken_link_report.folders.map(&:name), "radio_sample_flow"
    end
  end

  context "#folder_paths" do
    should "include the child folders within the root folder" do
      child_path = File.expand_path("outcomes", path)
      assert_includes broken_link_report.folder_paths, child_path
    end
  end

  context "Folder#name" do
    should "be the name of the parent folder" do
      assert_equal "radio_sample_flow", folder.name
    end
  end

  context "#erb_files" do
    should "include the paths to erb files withing the folder" do
      assert_includes folder.erb_files, erb_file_path
    end
  end

  context "Folder#texts" do
    should "include the text content for erb files in the folder" do
      assert_includes folder.texts, erb_file_content
    end
  end

  context "Folder#link_checker" do
    should "be an instance of line checker" do
      assert_kind_of LinkChecker, folder.link_checker
    end
  end
end
