module SmartAnswer
  class NationalMinimumWageFlow < Flow
    def define
      content_id 'f2c42b26-eb74-4ba1-88a2-9ef7d8044294'
      name 'national-minimum-wage'

      status :draft
      satisfies_need '100145'
    end
  end
end
