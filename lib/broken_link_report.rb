class BrokenLinkReport
  def self.for_erb_files_at(flows_root_path)
    new(flows_root_path).summary_report
  end

  attr_reader :flows_root_path

  def initialize(flows_root_path)
    @flows_root_path = flows_root_path
  end

  def folder_paths
    path_to_items_within_root_folder = File.join(flows_root_path, "*")
    Dir.glob(path_to_items_within_root_folder).select { |file| File.directory?(file) }
  end

  def folders
    @folders ||= folder_paths.map { |folder_path| Folder.new(folder_path) }
  end

  def summary_report
    @summary_report ||= begin
      report = folders.each_with_object([]) do |folder, content|
        next unless folder.report
        next if folder.totals.links == folder.totals.ok

        content << "Flow: #{folder.name}"
        content << "===================="
        folder.links.each do |link|
          next unless %i[broken caution].include?(link.status)

          content << link.uri
          content << link.problem_summary
          content << link.errors.join("\n") if link.errors.present?
          content << link.suggested_fix if link.suggested_fix.present?
          content << ""
        end
        content << ""
      end
      report.join("\n")
    end
  end

  class Folder
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def name
      @name ||= File.basename(path)
    end

    def erb_files
      Dir.glob(File.join(path, "**/*.erb"))
    end

    def texts
      erb_files.map { |file_path| File.read(file_path) }
    end

    def link_checker
      @link_checker ||= LinkChecker.new(texts)
    end
    delegate :report, to: :link_checker
    delegate :totals, :links, to: :report, allow_nil: true
  end
end
