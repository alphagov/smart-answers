/* eslint-env jasmine */
/* global GOVUK */

describe('An autocomplete component', function () {
  var autocomplete, fixture

  function loadAutocompleteComponent (markup) {
    fixture = document.createElement('div')
    document.body.appendChild(fixture)
    fixture.innerHTML = markup
    autocomplete = new GOVUK.Modules.Autocomplete(fixture.querySelector('.app-c-autocomplete'))
  }

  var html =
    '<div class="app-c-autocomplete govuk-form-group" data-module="autocomplete">' +
      '<label for="autocomplete-id" class="gem-c-label govuk-label">Countries</label>' +
      '<input name="autocomplete-name" id="autocomplete-id" class="govuk-input" list="autocomplete-list" type="text">' +
      '<datalist id="autocomplete-list">' +
        '<option value="France"></option>' +
        '<option value="Germany"></option>' +
      '</datalist>' +
    '</div>'

  var htmlWithoutDataList =
  '<div class="app-c-autocomplete govuk-form-group" data-module="autocomplete">' +
    '<label for="autocomplete-id" class="gem-c-label govuk-label">Countries</label>' +
    '<input name="autocomplete-name" id="autocomplete-id" class="govuk-input" list="autocomplete-list" type="text">' +
  '</div>'

  var htmlWithInputValue =
    '<div class="app-c-autocomplete govuk-form-group" data-module="autocomplete">' +
      '<label for="autocomplete-id" class="gem-c-label govuk-label">Countries</label>' +
      '<input name="autocomplete-name" id="autocomplete-id" class="govuk-input" list="autocomplete-list" type="text" value="test value">' +
      '<datalist id="autocomplete-list">' +
        '<option value="France"></option>' +
        '<option value="Germany"></option>' +
      '</datalist>' +
    '</div>'

  afterEach(function () {
    fixture.remove()
  })

  it('fails gracefully if there is no datalist', function () {
    loadAutocompleteComponent(htmlWithoutDataList)
    spyOn(autocomplete, 'getDataListContents').and.callThrough()
    autocomplete.init()

    expect(autocomplete.getDataListContents).not.toHaveBeenCalled()
  })

  it('deletes the original input', function () {
    loadAutocompleteComponent(html)
    spyOn(autocomplete, 'getDataListContents').and.callThrough()
    autocomplete.init()

    expect(autocomplete.getDataListContents).toHaveBeenCalled()
    var inputs = fixture.querySelectorAll('input')
    expect(inputs.length).toEqual(1)
  })

  it('recreates the input exactly', function () {
    loadAutocompleteComponent(html)
    autocomplete.init()

    var input = fixture.querySelector('input')
    expect(input.getAttribute('name')).toEqual('autocomplete-name')
    expect(input.getAttribute('id')).toEqual('autocomplete-id')
    expect(input.getAttribute('type')).toEqual('text')
  })

  it('recreates the input with the same value', function () {
    loadAutocompleteComponent(htmlWithInputValue)
    autocomplete.init()

    var input = fixture.querySelector('input')
    expect(input.value).toEqual('test value')
  })
})
