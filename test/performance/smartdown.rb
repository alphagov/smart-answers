require 'rails'
require 'active_support/all'
require 'benchmark'
require 'filesize'
require_relative "memory.rb"

#Don't ask
module Rails
  def self.root
    Pathname.new `pwd`.chomp
  end
end

require_relative '../../lib/smartdown_adapter/registry.rb'
require_relative '../../lib/smartdown_adapter/plugin_factory.rb'

module Benchmarker
  REGISTRY_OPTIONS = { load_path: "#{`pwd`.chomp}/lib/smartdown_flows/", show_drafts: true}

  COMPLICATED_RESPONSES = ['birth', 'yes', '2016-1-1', 'worker', 'employee', 'yes', 'yes', '400-week', 'yes', 'yes', 'yes', '400-week', 'yes']

  THINGS_TO_BENCHMARK = [
    ["Loading All flows", -> { all_flows }],
    ["Selecting 'start' on spl", -> {  spl_flow.state('y', [])}],
    ["Answering one question for spl", -> {  spl_flow.state('y', ['birth', 'yes'])}],
    ["Answering lots of questions with complicated outcome for spl", -> {  spl_flow.state('y', COMPLICATED_RESPONSES)}]
  ]

  def all_flows
    registry.flows
  end

  def spl_flow
    flow ||= registry.find 'employee-parental-leave'
  end

  def puts_time_taken &block
    time = Benchmark.realtime &block
    puts "Time taken: #{humanize time}"
  end

  def humanize secs
    if secs < 1
      return "#{secs} seconds"
    end
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        n = n.to_i unless name == :seconds
        "#{n} #{name}"
      end
    }.compact.reverse.join(' ')
  end

  def registry
    @@registry
  end

  def benchmark_with_and_without_preloading
    @@registry = SmartdownAdapter::Registry.instance(REGISTRY_OPTIONS)
    puts "PRELOADING TURNED OFF"
    benchmark_things

    SmartdownAdapter::Registry.reset_instance
    @@registry = SmartdownAdapter::Registry.instance(REGISTRY_OPTIONS.merge({ preload_flows: true }))
    puts "PRELOADING TURNED ON"
    benchmark_things

    puts
    memory_footprint = Filesize.from("#{Memory.analyze(@@registry.flows).bytes} B").pretty
    puts "Size of all the preloaded flows: #{memory_footprint}"
    puts
  end

  def benchmark_things
    THINGS_TO_BENCHMARK.each do |description, code|
      puts description
      puts_time_taken &code
      puts
    end
    puts
  end

  extend self
end

if __FILE__ == $0
  Benchmarker.benchmark_with_and_without_preloading
end
