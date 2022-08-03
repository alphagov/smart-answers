class VisaBannerFlow < SmartAnswer::Flow
  def define
    name "check-uk-visa"
    status :published

    radio :questions do
      option "yes"
      option "no"

      next_node do
        outcome :done
      end
    end

    outcome :done
  end
end
