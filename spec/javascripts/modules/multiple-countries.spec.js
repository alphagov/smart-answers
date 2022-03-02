describe('Multiple Countries', function () {
  var container
  var defaultHtml =
    '<div>' +
      '<div class="js-countries">' +
        '<div class="js-country">' +
          '<input/>' +
        '</div>' +
        '<div class="js-country">' +
          '<input/>' +
        '</div>' +
        '<div class="js-country">' +
          '<input/>' +
        '</div>' +
      '</div>' +
    '</div>'

  afterEach(function () {
    document.body.removeChild(container)
  })

  describe('when initialised on a fresh page', function () {
    beforeEach(function () {
      container = document.createElement('div')
      container.innerHTML = defaultHtml
      document.body.appendChild(container)
      var mc = new window.GOVUK.Modules.MultipleCountries(container)
      mc.init()
    })

    it('hides all but one of the countries', function () {
      var hidden_countries = container.querySelectorAll('.js-country[hidden]')
      expect(hidden_countries.length).toBe(2)
    })

    it('creates a remove button for each country', function () {
      var countries = container.querySelectorAll('.js-country')
      for (var i = 0; i < countries.length; i++) {
        var removeButton = countries[i].querySelectorAll('button')
        expect(removeButton.length).toBe(1)
        expect(removeButton[0].textContent).toEqual('Remove this country')
      }
    })

    it('creates an add new country button', function () {
      var buttons = container.querySelectorAll('button')
      expect(buttons[buttons.length - 1].textContent).toEqual('Add another country')
    })
  })

  describe('when initialised on a page where countries have been selected', function () {
    beforeEach(function () {
      container = document.createElement('div')
      container.innerHTML =
        '<div>' +
          '<div class="js-countries">' +
            '<div class="js-country">' +
              '<input value="Uganda"/>' +
            '</div>' +
            '<div class="js-country">' +
              '<input value="Ukraine"/>' +
            '</div>' +
            '<div class="js-country">' +
              '<input/>' +
            '</div>' +
          '</div>' +
        '</div>'
      document.body.appendChild(container)
      var mc = new window.GOVUK.Modules.MultipleCountries(container)
      mc.init()
    })

    it('hides all countries except those with values', function () {
      var hidden_countries = container.querySelectorAll('.js-country[hidden]')
      expect(hidden_countries.length).toBe(1)
    })
  })

  describe('after initialisation', function () {
    beforeEach(function () {
      container = document.createElement('div')
      container.innerHTML = defaultHtml
      document.body.appendChild(container)
      var mc = new window.GOVUK.Modules.MultipleCountries(container)
      mc.init()
    })

    it('can add more countries', function () {
      var hidden_countries = container.querySelectorAll('.js-country[hidden]')
      expect(hidden_countries.length).toBe(2)

      var addButton = container.querySelectorAll('button')
      addButton = addButton[addButton.length - 1]
      addButton.click()

      hidden_countries = container.querySelectorAll('.js-country[hidden]')
      expect(hidden_countries.length).toBe(1)
    })

    it('can remove a country', function () {
      var firstCountry = container.querySelector('.js-country')
      var firstCountryInput = firstCountry.querySelector('input')
      var firstCountryRemove = firstCountry.querySelector('button')

      firstCountryInput.value = 'test'
      firstCountryRemove.click()

      var hidden_countries = container.querySelectorAll('.js-country[hidden]')
      expect(hidden_countries.length).toBe(3)
      expect(firstCountryInput.value).toEqual('')
    })
  })
})
