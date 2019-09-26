module ApplicationHelper
  def last_updated_date
    File.mtime(Rails.root.join("REVISION")).to_date rescue Date.today
  end

  def current_path_without_query_string
    request.original_fullpath.split("?", 2).first
  end
end
