require 'ostruct'

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task register: :environment do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    PanopticonRegisterer.new(flow_presenters).register
  end
end
