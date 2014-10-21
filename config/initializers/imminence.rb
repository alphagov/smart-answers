require 'gds_api/imminence'

$imminence = GdsApi::Imminence.new(Plek.current.find('imminence'))
