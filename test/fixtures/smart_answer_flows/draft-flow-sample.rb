module SmartAnswer
  class DraftFlowSampleFlow < Flow
    def define
      name "draft-flow-sample"
      status :draft

      start_page
    end
  end
end
