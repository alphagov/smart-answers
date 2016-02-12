//= require govuk/multivariate-test

$(function(){
  if(window.location.href.indexOf("/overseas-passports") > -1) {
    new GOVUK.MultivariateTest({
      el: '.get-started a',
      name: 'startButton_osPassport_201602',
      customDimensionIndex: 13,
      contentExperimentId: 'egf8SiUzQJmsUuEIbxkCRw',
      cohorts: {
        original: { callback: function() {}, variantId: 0 },
        getApplicationInfo: { html: 'Get application information', variantId: 1 },
        next: { html: 'Next', variantId: 2 }
      }
    });
  }

  if(window.location.href.indexOf("/calculate-your-child-maintenance") > -1) {
    new GOVUK.MultivariateTest({
      el: '.get-started a',
      name: 'startButton_calcChildM_201602',
      customDimensionIndex: 13,
      contentExperimentId: 'u0MzUmYRRzmb5mchoGp9Fw',
      cohorts: {
        original: { callback: function() {}, variantId: 0 },
        calculate: { html: 'Calculate', variantId: 1 },
        estimateChildMaintenance: { html: 'Estimate your child maintenance', variantId: 2 }
      }
    });
  }

  if(window.location.href.indexOf("/marriage-abroad") > -1) {
    new GOVUK.MultivariateTest({
      el: '.get-started a',
      name: 'startButton_marriageAbroad_201602',
      customDimensionIndex: 13,
      contentExperimentId: 'Xk_FTKgiTwikoIH0fzPklw',
      cohorts: {
        original: { callback: function() {}, variantId: 0 },
        findOutHow: { html: 'Find out how', variantId: 1 },
        getMoreInfo: { html: 'Get more information', variantId: 2 }
      }
    });
  }
});
