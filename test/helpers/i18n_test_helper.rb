module I18nTestHelper
  def using_translation_file(filename, &block)
    @i18n_load_path_stack ||= []
    @i18n_load_path_stack.push I18n.config.load_path.dup
    I18n.config.load_path.unshift(filename)
    I18n.reload!
    yield
    I18n.config.load_path = @i18n_load_path_stack.pop
    I18n.reload!
  end
  
  def fixture_file(filename)
    File.expand_path("../../fixtures/#{filename}", __FILE__)
  end
end