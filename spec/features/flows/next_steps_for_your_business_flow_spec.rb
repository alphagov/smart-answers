RSpec.feature "SmartAnswer::NextStepsForYourBusinessFlow" do
  let(:headings) do
    # <question name>: <text_for :title from erb>
    {
      flow_title: "Check the next steps for your limited company",
      annual_turnover_over_85k: "Do you think your business will take more than £85,000 in a 12 month period?",
      employ_someone: "Do you want to employ someone?",
      activities: "Does your business do any of the following?",
      financial_support: "Are you looking for financial support for?",
      business_premises: "Where are you running your business?",
      results: "Next steps for your limited company",
    }
  end

  let(:answers) do
    {
      annual_turnover_over_85k: "Yes",
      employ_someone: "Not sure",
      activities: "Buy items from abroad",
      financial_support: "Yes",
      business_premises: "From home",
    }
  end

  before do
    stub_content_store_has_item("/next-steps-for-your-business")
    start(the_flow: headings[:flow_title], at: "next-steps-for-your-business")
  end

  scenario "Answers all questions" do
    answer(question: headings[:annual_turnover_over_85k], of_type: :radio, with: answers[:annual_turnover_over_85k])
    answer(question: headings[:employ_someone], of_type: :radio, with: answers[:employ_someone])
    answer(question: headings[:activities], of_type: :checkbox, with: answers[:activities])
    answer(question: headings[:financial_support], of_type: :radio, with: answers[:financial_support])
    answer(question: headings[:business_premises], of_type: :checkbox, with: answers[:business_premises])

    ensure_page_has(header: headings[:results])
  end
end
