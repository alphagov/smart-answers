module WorldLocationStubbingMethods
  def stub_world_location(location_slug)
    location = stub.quacks_like(WorldLocation.new({}))
    location.stubs(:slug).returns(location_slug)
    location.stubs(:name).returns(location_slug.humanize)
    location.stubs(:fco_organisation).returns(nil)
    WorldLocation.stubs(:find).with(location_slug).returns(location)
    location
  end

  def stub_world_locations(location_slugs)
    locations = location_slugs.map do |slug|
      stub_world_location(slug)
    end
    WorldLocation.stubs(:all).returns(locations)
  end
end
