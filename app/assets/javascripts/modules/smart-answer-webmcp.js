window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  const INSTRUCTIONS = 'Send every answer you know, keyed by question name, ' +
    'or {} to start. Answer a returned question from what you know, or ask ' +
    'the user with its requestedSchema, then call again with all your ' +
    'answers. When you change an answer, drop the answers to later ' +
    'questions. Stop when status is outcome.'

  function SmartAnswerWebmcp (module) {
    this.module = module
    this.flowId = module.dataset.flowId
  }

  SmartAnswerWebmcp.prototype.init = function () {
    if (!document.modelContext) return

    document.modelContext.registerTool({
      name: this.module.dataset.toolName,
      title: this.module.dataset.flowTitle,
      description: this.module.dataset.flowTitle + '. ' + INSTRUCTIONS,
      inputSchema: JSON.parse(this.module.dataset.inputSchema),
      outputSchema: JSON.parse(this.module.dataset.outputSchema),
      annotations: { readOnlyHint: true },
      execute: this.execute.bind(this)
    })
  }

  SmartAnswerWebmcp.prototype.execute = function (input, options) {
    // URLSearchParams joins checkbox arrays with commas, which Checkbox#parse_input splits
    const query = new URLSearchParams(input)

    return fetch('/' + this.flowId + '/step?' + query, { signal: options.signal })
      .then(function (response) {
        if (!response.ok) throw new Error('Step failed: ' + response.status)
        return response.json()
      })
  }

  Modules.SmartAnswerWebmcp = SmartAnswerWebmcp
})(window.GOVUK.Modules)
