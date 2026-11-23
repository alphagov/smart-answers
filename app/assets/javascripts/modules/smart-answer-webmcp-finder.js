window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  const DESCRIPTION = 'Call with {} to list every smart answer with its ' +
    'title and a one-line description. Then call with the slug that fits ' +
    'the user\'s question to open that flow\'s start page, where its own ' +
    'tool registers.'

  function SmartAnswerWebmcpFinder (module) {
    this.module = module
    this.flows = JSON.parse(module.dataset.flows)
  }

  SmartAnswerWebmcpFinder.prototype.init = function () {
    if (!document.modelContext) return

    document.modelContext.registerTool({
      name: 'find_smart_answer',
      title: 'Find a smart answer',
      description: DESCRIPTION,
      inputSchema: JSON.parse(this.module.dataset.inputSchema),
      outputSchema: JSON.parse(this.module.dataset.outputSchema),
      execute: this.execute.bind(this)
    })
  }

  SmartAnswerWebmcpFinder.prototype.execute = function (input) {
    if (!input.slug) return Promise.resolve({ flows: this.flows })

    const flow = this.flows.find(function (flow) { return flow.slug === input.slug })
    if (!flow) return Promise.reject(new Error('Unknown smart answer: ' + input.slug))

    this.open(flow.url)
    return Promise.resolve({ opened: flow.url })
  }

  SmartAnswerWebmcpFinder.prototype.open = function (url) {
    window.location.assign(url)
  }

  Modules.SmartAnswerWebmcpFinder = SmartAnswerWebmcpFinder
})(window.GOVUK.Modules)
