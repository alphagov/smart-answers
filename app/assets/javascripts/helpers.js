var SmartAnswer = window.SmartAnswer || {}

SmartAnswer.isStartPage = function (slug) { // Used mostly during A/B testing
  return window.location.pathname.split('/').join('') === slug
}
