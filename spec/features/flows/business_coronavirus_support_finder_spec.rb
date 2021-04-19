RSpec.feature "SmartAnswer::BusinessCoronavirusSupportFinderFlow" do
  let(:headings) do
    # <question name>: <text_for :title from erb>
    {
      flow_title: "Find coronavirus financial support for your business",
      business_based: "Where is your business based?",
      business_size: "How many employees does your business have?",
      non_domestic_property: "Does your business have any rateable non-domestic property?",
      paye_scheme: "Are you an employer with a PAYE scheme?",
      sectors: "Select your type of business",
      self_assessment_july_2020: "Are you due to pay a Self Assessment payment on account by 31 July 2020?",
      what_size_was_your_buisness: "What size was your business as of 28 February?",
      closed_by_restrictions: "Has your business closed by law because of coronavirus?",
      results: "Financial support your business might be entitled to",
    }
  end

  let(:answers) do
    {
      england: "England",
      yes: "Yes",
      no: "No",
      employees: "0 to 249 employees",
      property: "Yes",
      non_adult: "Nurseries",
      adult: "Nightclub, dancehall, or adult entertainment venue",
    }
  end

  before do
    stub_content_store_has_item("/business-coronavirus-support-finder")
    start(the_flow: headings[:flow_title], at: "business-coronavirus-support-finder")
  end

  scenario "Answers all questions" do
    answer(question: headings[:business_based], of_type: :radio, with: answers[:england])
    answer(question: headings[:business_size], of_type: :radio, with: answers[:employees])
    answer(question: headings[:paye_scheme], of_type: :radio, with: answers[:yes])
    answer(question: headings[:non_domestic_property], of_type: :radio, with: answers[:property])
    answer(question: headings[:sectors], of_type: :checkbox, with: answers[:non_adult])
    answer(question: headings[:closed_by_restrictions], of_type: :checkbox, with: answers[:no])

    ensure_page_has(header: headings[:results])
  end

  scenario "Skip last question if business type nightclubs" do
    answer(question: headings[:business_based], of_type: :radio, with: answers[:england])
    answer(question: headings[:business_size], of_type: :radio, with: answers[:employees])
    answer(question: headings[:paye_scheme], of_type: :radio, with: answers[:yes])
    answer(question: headings[:non_domestic_property], of_type: :radio, with: answers[:property])
    answer(question: headings[:sectors], of_type: :checkbox, with: answers[:adult])

    ensure_page_has(header: headings[:results])
  end
end
