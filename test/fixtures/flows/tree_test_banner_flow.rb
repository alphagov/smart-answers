class TreeTestBannerFlow < SmartAnswer::Flow
  def define
    name "maternity-paternity-pay-leave"
    status :published

    radio :two_carers do
      option "yes"
      option "no"

      next_node do
        outcome :done
      end
    end

    outcome :done
  end
end
