class StartNodePresenter < NodePresenter
  def i18n_node_prefix
    @i18n_prefix
  end

  def has_meta_description?
    !!meta_description
  end

  def meta_description
    translate!('meta.description')
  end

  def has_post_body?
    !!post_body
  end

  def post_body(html: true)
    translate_and_render('post_body', html: html)
  end
end
