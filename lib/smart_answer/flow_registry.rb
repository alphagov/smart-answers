SMART_ANSWER_FLOW_NAMES = %w(
  additional-commodity-code
  am-i-getting-minimum-wage
  apply-tier-4-visa
  benefit-cap-calculator
  calculate-agricultural-holiday-entitlement
  calculate-employee-redundancy-pay
  calculate-married-couples-allowance
  calculate-state-pension
  calculate-statutory-sick-pay
  calculate-your-child-maintenance
  calculate-your-holiday-entitlement
  calculate-your-redundancy-pay
  check-uk-visa
  childcare-costs-for-tax-credits
  energy-grants-calculator
  estimate-self-assessment-penalties
  help-if-you-are-arrested-abroad
  inherits-someone-dies-without-will
  legalisation-document-checker
  marriage-abroad
  maternity-paternity-calculator
  minimum-wage-calculator-employers
  overseas-passports
  pip-checker
  plan-adoption-leave
  register-a-birth
  register-a-death
  report-a-lost-or-stolen-passport
  simplified-expenses-checker
  state-pension-through-partner
  state-pension-topup
  student-finance-calculator
  towing-rules
  uk-benefits-abroad
  vat-payment-deadlines
)

SMART_ANSWER_FLOW_NAMES.each do |name|
  require "smart_answer_flows/#{name}"
end

SMART_ANSWER_TEST_FLOW_NAMES = %w(
  bridge-of-death
  checkbox-sample
)

SMART_ANSWER_TEST_FLOW_NAMES.each do |name|
  require Rails.root.join("test/fixtures/smart_answer_flows/#{name}")
end

module SmartAnswer
  class FlowRegistry
    class NotFound < StandardError; end
    FLOW_DIR = Rails.root.join('lib', 'smart_answer_flows')

    def self.instance
      @instance ||= new(FLOW_REGISTRY_OPTIONS)
    end

    def self.reset_instance
      @instance = nil
    end

    def initialize(options = {})
      @load_path = Pathname.new(options[:smart_answer_load_path] || FLOW_DIR)
      @show_drafts = options.fetch(:show_drafts, false)
      @show_transitions = options.fetch(:show_transitions, false)
      preload_flows! if Rails.env.production? or options[:preload_flows]
    end
    attr_reader :load_path

    def find(name)
      raise NotFound unless available?(name)
      find_by_name(name) or raise NotFound
    end

    def flows
      available_flows.map { |s| find_by_name(s) }.compact
    end

    def available_flows
      Dir[@load_path.join('*.rb')].map do |path|
        File.basename(path, ".rb")
      end
    end

  private
    def find_by_name(name)
      flow = @preloaded ? preloaded(name) : build_flow(name)
      return nil if flow && flow.draft? && !@show_drafts
      return nil if flow && flow.transition? && !@show_transitions
      flow
    end

    def available?(name)
      if @preloaded
        @preloaded.has_key?(name)
      else
        available_flows.include?(name)
      end
    end

    def build_flow(name)
      if (SMART_ANSWER_FLOW_NAMES + SMART_ANSWER_TEST_FLOW_NAMES).include?(name)
        class_prefix = name.gsub("-", "_").camelize
        load "smart_answer_flows/#{name}.rb" if Rails.env.development?
        namespaced_class = "SmartAnswer::#{class_prefix}Flow".constantize
        namespaced_class.build
      else
        absolute_path = @load_path.join("#{name}.rb").to_s
        Flow.new do
          eval(File.read(absolute_path), binding, absolute_path)
          name(name)
        end
      end
    end

    def preload_flows!
      @preloaded = {}
      available_flows.each do |flow_name|
        @preloaded[flow_name] = build_flow(flow_name)
      end
    end

    def preloaded(name)
      @preloaded && @preloaded[name]
    end
  end
end
