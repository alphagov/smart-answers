namespace :retire do
  desc "Unpublish a content item with a redirect"
  task :unpublish_redirect, %i[content_id base_path destination] => :environment do |_, args|
    raise "Missing content_id parameter" if args.content_id.blank?
    raise "Missing base_path parameter" if args.base_path.blank?
    raise "Missing destination parameter" if args.destination.blank?

    redirect = { path: args.base_path, type: "prefix", destination: args.destination }
    Services.publishing_api.unpublish(args.content_id,
                                      type: "redirect",
                                      redirects: [redirect])
  end

  desc "Unpublish a content item with a type of gone"
  task :unpublish_gone, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    Services.publishing_api.unpublish(args.content_id, type: "gone")
  end

  desc "Unpublish a content item with a type of vanish"
  task :unpublish_vanish, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    Services.publishing_api.unpublish(args.content_id, type: "vanish")
  end

  desc "Change publishing application"
  task :change_owning_application, %i[base_path publishing_app] => :environment do |_, args|
    raise "Missing base_path parameter" unless args.base_path
    raise "Missing publishing_app parameter" unless args.publishing_app

    Services.publishing_api.put_path(args.base_path,
                                     publishing_app: args.publishing_app,
                                     override_existing: true)
  end
end
