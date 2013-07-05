require 'gds_api/fact_cave'

$fact_cave = GdsApi::FactCave.new(Plek.current.find('fact-cave'))
