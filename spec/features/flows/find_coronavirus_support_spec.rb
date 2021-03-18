RSpec.feature "FindCoronavirusSupportFlow" do
  let(:questions) do
    {
      flow_title: "Find out what support you can get if you’re affected by coronavirus",
      need_help_with: "What do you need help with because of coronavirus?",
      feel_unsafe: "Do you feel unsafe where you live?",
      afford_rent_mortgage_bills: "Are you finding it hard to pay your rent, mortgage or bills?",
      afford_food: "Are you finding it hard to afford food?",
      get_food: "Are you able to get food or medicine?",
      self_employed: "Are you self-employed, a freelancer, or a sole trader?",
      have_you_been_made_unemployed: "Have you been made redundant or told to stop working?",
      worried_about_work: "Are you worried about going in to work?",
      worried_about_self_isolating: "Are you self-isolating?",
      have_somewhere_to_live: "Do you have somewhere to live?",
      have_you_been_evicted: "Have you been evicted?",
      mental_health_worries: "Are you worried about your mental health, or another adult or child’s mental health?",
      nation: "Where do you want to find information about?",
      results: "Information based on your answers",
    }
  end

  let(:results) do
    {
      feeling_unsafe: "If you feel unsafe where you live or you’re worried about someone else",
      paying_bills: "If you’re finding it hard to pay your rent, mortgage or bills",
      afford_food: "If you’re finding it hard to afford food",
      get_food: "If you’re unable to get food or medicine",
      unemployed_furlough: "If you’ve been made redundant or unemployed, or put on temporary leave (on furlough)",
      unemployed_self_employed: "If you’re self employed, a freelancer, or a sole trader",
      going_to_work: "If you’re worried about going in to work",
      self_isolating: "If you’re self-isolating",
      somewhere_to_live: "If you do not have somewhere to live or might become homeless",
      evicted: "If you’ve been evicted or might be soon",
      mental_health: "If you’re worried about your mental health or someone else’s mental health",
      no_results: "Based on your answers, there’s no specific information for you in this service at the moment",
    }
  end

  let(:need_help_with) do
    {
      feeling_unsafe: "Feeling unsafe where you live, or what to do if you’re worried about the safety of another adult or child",
      paying_bills: "Paying your rent, mortgage, or bills",
      getting_food: "Getting food or medicine",
      being_unemployed: "Being made redundant or unemployed, or not having any work if you're self-employed",
      going_to_work: "Being worried about working",
      self_isolating: "Self-isolating",
      somewhere_to_live: "Having somewhere to live",
      mental_health: "Mental health and wellbeing, including information for children",
      none: "None of these",
    }
  end

  let(:answers) do
    {
      england: "England",
      yes: "Yes",
      yes_i_am: "Yes, I am",
      yes_redundant: "Yes, I’ve been made redundant or I’m out of work, or might be soon",
      no: "No",
    }
  end

  before do
    stub_content_store_has_item("/find-coronavirus-support")
    start(the_flow: questions[:flow_title], at: "find-coronavirus-support")
  end

  scenario "feeling unsafe" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:feeling_unsafe])
    answer(question: questions[:feel_unsafe], of_type: :radio, with: answers[:yes])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: results[:feeling_unsafe])
  end

  scenario "paying bills" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:paying_bills])
    answer(question: questions[:afford_rent_mortgage_bills], of_type: :radio, with: answers[:yes])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: results[:paying_bills])
  end

  scenario "affording and getting food" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:getting_food])
    answer(question: questions[:afford_food], of_type: :radio, with: answers[:yes])
    answer(question: questions[:get_food], of_type: :radio, with: answers[:no])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: [results[:afford_food], results[:get_food]])
  end

  scenario "being unemployed" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:being_unemployed])
    answer(question: questions[:self_employed], of_type: :radio, with: answers[:no])
    answer(question: questions[:have_you_been_made_unemployed], of_type: :radio, with: answers[:yes_redundant])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: results[:unemployed_furlough])
  end

  scenario "being unemployed - self-employed" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:being_unemployed])
    answer(question: questions[:self_employed], of_type: :radio, with: answers[:yes])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: results[:unemployed_self_employed])
  end

  scenario "going to work" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:going_to_work])
    answer(question: questions[:worried_about_work], of_type: :radio, with: answers[:yes])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: results[:going_to_work])
  end

  scenario "self isolating" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:self_isolating])
    answer(question: questions[:worried_about_self_isolating], of_type: :radio, with: answers[:yes])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: results[:self_isolating])
  end

  scenario "somewhere to live" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:somewhere_to_live])
    answer(question: questions[:have_somewhere_to_live], of_type: :radio, with: answers[:no])
    answer(question: questions[:have_you_been_evicted], of_type: :radio, with: answers[:yes])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: [results[:somewhere_to_live], results[:evicted]])
  end

  scenario "mental health" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:mental_health])
    answer(question: questions[:mental_health_worries], of_type: :radio, with: answers[:yes_i_am])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], subheaders: results[:mental_health])
  end

  scenario "None of these" do
    answer(question: questions[:need_help_with], of_type: :checkbox, with: need_help_with[:none])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(header: questions[:results], text: results[:no_results])
  end

  scenario "all the options" do
    answer(
      question: questions[:need_help_with],
      of_type: :checkbox,
      with: [
        need_help_with[:mental_health],
        need_help_with[:somewhere_to_live],
        need_help_with[:going_to_work],
        need_help_with[:self_isolating],
        need_help_with[:being_unemployed],
        need_help_with[:getting_food],
        need_help_with[:paying_bills],
        need_help_with[:feeling_unsafe],
      ],
    )

    answer(question: questions[:feel_unsafe], of_type: :radio, with: answers[:yes])
    answer(question: questions[:afford_rent_mortgage_bills], of_type: :radio, with: answers[:yes])
    answer(question: questions[:afford_food], of_type: :radio, with: answers[:yes])
    answer(question: questions[:get_food], of_type: :radio, with: answers[:yes])
    answer(question: questions[:self_employed], of_type: :radio, with: answers[:yes])
    answer(question: questions[:worried_about_work], of_type: :radio, with: answers[:yes])
    answer(question: questions[:worried_about_self_isolating], of_type: :radio, with: answers[:yes])
    answer(question: questions[:have_somewhere_to_live], of_type: :radio, with: answers[:yes])
    answer(question: questions[:have_you_been_evicted], of_type: :radio, with: answers[:yes])
    answer(question: questions[:mental_health_worries], of_type: :radio, with: answers[:yes_i_am])
    answer(question: questions[:nation], of_type: :radio, with: answers[:england])

    ensure_page_has(
      header: questions[:results],
      subheaders: [
        results[:feeling_unsafe],
        results[:paying_bills],
        results[:afford_food],
        results[:unemployed_self_employed],
        results[:going_to_work],
        results[:self_isolating],
        results[:evicted],
        results[:mental_health],
      ],
    )
  end
end
