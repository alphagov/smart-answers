require 'gds_api/imminence'

$imminence = GdsApi::Imminence.new(Plek.new.find('imminence'))
