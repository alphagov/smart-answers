module ApplicationHelper
  def current_path_without_query_string
    request.original_fullpath.split("?", 2).first
  end
end
