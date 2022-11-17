namespace :publishing_api do
  desc "Sync all smart answers with the Publishing API"
  task sync_all: [:environment] do
    flows = SmartAnswer::FlowRegistry.instance.flows
    ContentItemSyncer.new.sync(flows)
  end

  desc "Sync a single smart answer with the Publishing API"
  task :sync, %i[slug] => [:environment] do |_, args|
    to_sync = SmartAnswer::FlowRegistry.instance.flows.find do |flow|
      flow.name == args[:slug]
    end

    raise "Smart Answer #{args[:slug]} not found" unless to_sync

    ContentItemSyncer.new.sync([to_sync])
  end

  desc "Unpublish a content item with a redirect"
  task :unpublish_redirect, %i[content_id base_path destination type] => :environment do |_, args|
    raise "Missing content_id parameter" if args.content_id.blank?
    raise "Missing base_path parameter" if args.base_path.blank?
    raise "Missing destination parameter" if args.destination.blank?

    type = args.type || "prefix"

    redirect = {
      path: args.base_path,
      segments_mode: "ignore",
      type:,
      destination: args.destination,
    }
    GdsApi.publishing_api.unpublish(
      args.content_id,
      type: "redirect",
      redirects: [redirect],
      discard_drafts: true,
    )
  end

  desc "Unpublish a content item with a type of gone"
  task :unpublish_gone, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    GdsApi.publishing_api.unpublish(args.content_id, type: "gone", discard_drafts: true)
  end

  desc "Unpublish a content item with a type of vanish"
  task :unpublish_vanish, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    GdsApi.publishing_api.unpublish(args.content_id, type: "vanish", discard_drafts: true)
  end

  desc "Change publishing application"
  task :change_owning_application, %i[base_path publishing_app] => :environment do |_, args|
    raise "Missing base_path parameter" unless args.base_path
    raise "Missing publishing_app parameter" unless args.publishing_app

    GdsApi.publishing_api.put_path(
      args.base_path,
      publishing_app: args.publishing_app,
      override_existing: true,
    )
  end
end
