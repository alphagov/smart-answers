/*
* We want to keep the jasmine/standardx functionality for tests in this repo, however they both crash if no JS spec files exist.
* Therefore we can keep this dummy test in. It can be removed if real tests are written for something in the future.
*/

describe('dummy test', function () {
  it('accepts the truth', function () {
    expect(true).toBe(true)
  })
})
