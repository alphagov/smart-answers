module I18nTestHelper
  def use_all_fixture_flow_translation_files
    @i18n_load_path_stack ||= []
    @i18n_load_path_stack.push I18n.config.load_path.dup
    I18n.load_path += Dir[Rails.root.join(*%w{test fixtures smart_answer_flows locales * *.{rb,yml}})]
    I18n.reload!
  end

  def using_additional_translation_file(filename, &block)
    use_additional_translation_file(filename)
    yield
    reset_translation_files!
  end

  def use_additional_translation_file(filename)
    @i18n_load_path_stack ||= []
    @i18n_load_path_stack.push I18n.config.load_path.dup
    I18n.config.load_path.unshift(filename)
    I18n.reload!
  end

  def reset_translation_files!
    I18n.config.load_path = @i18n_load_path_stack.pop
    I18n.reload!
  end
end
