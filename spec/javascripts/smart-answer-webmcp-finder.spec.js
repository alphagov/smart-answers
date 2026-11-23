describe('GOVUK.Modules.SmartAnswerWebmcpFinder', function () {
  const flows = [{
    slug: 'calculate-statutory-sick-pay',
    title: 'Calculate statutory sick pay',
    description: 'Work out statutory sick pay',
    url: '/calculate-statutory-sick-pay'
  }]
  let element, registered, finder

  beforeEach(function () {
    registered = undefined
    element = document.createElement('div')
    element.dataset.flows = JSON.stringify(flows)
    element.dataset.inputSchema = JSON.stringify({ type: 'object' })
    element.dataset.outputSchema = JSON.stringify({ type: 'object' })
    Object.defineProperty(document, 'modelContext', {
      value: { registerTool: function (tool) { registered = tool } },
      configurable: true
    })
    finder = new GOVUK.Modules.SmartAnswerWebmcpFinder(element)
    spyOn(finder, 'open')
    finder.init()
  })

  afterEach(function () {
    delete document.modelContext
  })

  it('registers find_smart_answer', function () {
    expect(registered.name).toBe('find_smart_answer')
    expect(registered.title).toBe('Find a smart answer')
    expect(registered.annotations).toBeUndefined()
  })

  it('lists the flows without a request', async function () {
    spyOn(window, 'fetch')

    expect(await registered.execute({})).toEqual({ flows })
    expect(window.fetch).not.toHaveBeenCalled()
  })

  it('opens the start page of the chosen flow', async function () {
    const result = await registered.execute({ slug: 'calculate-statutory-sick-pay' })

    expect(finder.open).toHaveBeenCalledWith('/calculate-statutory-sick-pay')
    expect(result).toEqual({ opened: '/calculate-statutory-sick-pay' })
  })

  it('rejects an unknown slug', async function () {
    await expectAsync(registered.execute({ slug: 'unknown' })).toBeRejected()
    expect(finder.open).not.toHaveBeenCalled()
  })
})
