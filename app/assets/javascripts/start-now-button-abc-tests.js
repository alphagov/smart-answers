//= require govuk/multivariate-test

$(function(){
  if(window.location.href.indexOf("/overseas-passports") > -1) {
    new GOVUK.MultivariateTest({
      el: '.get-started a',
      name: 'start-now-button-overseas-passports',
      cohorts: {
        control: { callback: function() {} },
        option_1: { html: 'Get application information' },
        option_2: { html: 'Next' }
      }
    });
  }

  if(window.location.href.indexOf("/calculate-your-child-maintenance") > -1) {
    new GOVUK.MultivariateTest({
      el: '.get-started a',
      name: 'start-now-button-calculate-your-child-maintenance',
      cohorts: {
        control: { callback: function() {} },
        option_1: { html: 'Calculate' },
        option_2: { html: 'Estimate your child maintenance' }
      }
    });
  }

  if(window.location.href.indexOf("/marriage-abroad") > -1) {
    new GOVUK.MultivariateTest({
      el: '.get-started a',
      name: 'start-now-button-marriage-abroad',
      cohorts: {
        control: { callback: function() {} },
        option_1: { html: 'Find out how' },
        option_2: { html: 'Get more information' }
      }
    });
  }
});
