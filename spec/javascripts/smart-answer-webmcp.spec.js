describe('GOVUK.Modules.SmartAnswerWebmcp', function () {
  const inputSchema = {
    type: 'object',
    properties: { first_sick_day_q: { type: 'string', format: 'date' } }
  }
  let element, registered

  beforeEach(function () {
    registered = undefined
    element = document.createElement('div')
    element.dataset.flowId = 'calculate-statutory-sick-pay'
    element.dataset.toolName = 'calculate_statutory_sick_pay'
    element.dataset.flowTitle = 'Calculate statutory sick pay'
    element.dataset.inputSchema = JSON.stringify(inputSchema)
    element.dataset.outputSchema = JSON.stringify({ type: 'object' })
    Object.defineProperty(document, 'modelContext', {
      value: { registerTool: function (tool) { registered = tool } },
      configurable: true
    })
  })

  afterEach(function () {
    delete document.modelContext
  })

  it('registers one tool, passing the schemas on unchanged', function () {
    new GOVUK.Modules.SmartAnswerWebmcp(element).init()

    expect(registered.name).toBe('calculate_statutory_sick_pay')
    expect(registered.title).toBe('Calculate statutory sick pay')
    expect(registered.description).toContain('Calculate statutory sick pay. ')
    expect(registered.annotations).toEqual({ readOnlyHint: true })
    expect(registered.inputSchema).toEqual(inputSchema)
    expect(registered.outputSchema).toEqual({ type: 'object' })
  })

  it('does nothing without document.modelContext', function () {
    Object.defineProperty(document, 'modelContext', { value: undefined, configurable: true })
    new GOVUK.Modules.SmartAnswerWebmcp(element).init()

    expect(registered).toBeUndefined()
  })

  it('fetches the step endpoint with the call\'s signal', function () {
    const signal = new AbortController().signal
    spyOn(window, 'fetch').and.returnValue(Promise.resolve(new Response('{}')))
    new GOVUK.Modules.SmartAnswerWebmcp(element).init()
    registered.execute({ first_sick_day_q: '2026-01-05', usual_work_days_q: ['1', '2'] }, { signal })

    expect(window.fetch).toHaveBeenCalledWith(
      '/calculate-statutory-sick-pay/step?first_sick_day_q=2026-01-05&usual_work_days_q=1%2C2',
      { signal }
    )
  })

  describe('after a call', function () {
    let module

    function call (reply) {
      spyOn(window, 'fetch').and.returnValue(Promise.resolve(new Response(JSON.stringify(reply))))
      module = new GOVUK.Modules.SmartAnswerWebmcp(element)
      spyOn(module, 'open')
      module.init()
      return registered.execute({}, { signal: new AbortController().signal })
    }

    beforeEach(function () {
      jasmine.clock().install()
    })

    afterEach(function () {
      jasmine.clock().uninstall()
    })

    it('returns the reply, then opens its url', async function () {
      const reply = { status: 'outcome', url: '/calculate-statutory-sick-pay/y/none' }
      const result = await call(reply)

      expect(result).toEqual(reply)
      expect(module.open).not.toHaveBeenCalled()

      jasmine.clock().tick(1)
      expect(module.open).toHaveBeenCalledWith('/calculate-statutory-sick-pay/y/none')
    })

    it('doesn\'t reopen the page it is on', async function () {
      await call({ status: 'question', url: window.location.pathname + window.location.search })
      jasmine.clock().tick(1)

      expect(module.open).not.toHaveBeenCalled()
    })
  })
})
