require 'ostruct'

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task register: :environment do
    registerables = RegisterableSmartAnswers.new.unique_registerables
    PanopticonRegisterer.new(registerables).register
  end
end
