require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/register-a-birth"

class RegisterABirthTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    @location_slugs = %w(afghanistan algeria andorra australia bangladesh barbados belize cambodia cameroon democratic-republic-of-the-congo el-salvador estonia germany guatemala grenada india iran iraq israel laos libya maldives morocco netherlands north-korea pakistan philippines pitcairn-island saint-barthelemy serbia sierra-leone somalia spain sri-lanka st-kitts-and-nevis st-martin thailand turkey uganda united-arab-emirates venezuela)
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::RegisterABirthFlow
  end

  should "ask which country the child was born in" do
    assert_current_node :country_of_birth?
  end

  context "answer Turkey" do
    setup do
      add_response 'turkey'
    end
    should "ask which parent has british nationality" do
      assert_current_node :who_has_british_nationality?
    end
    context "answer mother" do
      setup do
        add_response 'mother'
      end
      should "ask if you are married or civil partnered" do
        assert_current_node :married_couple_or_civil_partnership?
      end
      context "answer no" do
        setup do
          add_response 'no'
        end
        should "ask where you are now and go to oru result" do
          add_response "same_country"
          assert_current_node :oru_result
          assert current_state.calculator.send(:document_return_fees).present?
        end
      end # not married/cp
    end # mother
  end # Turkey

  context "answer with a commonwealth country" do
    should "give the commonwealth result" do
      add_response 'australia'
      assert_current_node :commonwealth_result
    end
  end # commonweath result

  context "answer Andorra" do
    should "store the correct registration country" do
      add_response 'andorra'
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_equal 'spain', current_state.calculator.registration_country
    end
  end # Andorra

  context "answer Israel" do
    should "show correct document variants" do
      add_response 'israel'
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_current_node :oru_result
    end
  end # Andorra

  context "answer Iran" do
    should "ask who has British nationality" do
      add_response 'iran'
      assert_current_node :who_has_british_nationality?
    end
  end # Iran

  context "answer Spain" do
    setup do
      add_response 'spain'
    end
    should "store this as the registration country" do
      assert_equal 'spain', current_state.calculator.registration_country
    end
    should "ask which parent has british nationality" do
      assert_current_node :who_has_british_nationality?
    end
    context "answer father" do
      setup do
        add_response 'father'
      end
      should "ask if you are married or civil partnered" do
        assert_current_node :married_couple_or_civil_partnership?
      end
      context "answer no" do
        setup do
          add_response 'no'
        end
        should "ask when the child was born" do
          assert_current_node :childs_date_of_birth?
        end
        context "answer pre 1st July 2006" do
          should "give the homeoffice result" do
            add_response '2006-06-30'
            assert_current_node :homeoffice_result
          end
        end
        context "answer on or after 1st July 2006" do
          setup do
            add_response '2006-07-01'
          end
          should "ask where you are now" do
            assert_current_node :where_are_you_now?
          end
        end
      end # not married/cp
    end # father is british citizen
    context "answer mother and father" do
      setup do
        add_response 'mother_and_father'
      end
      should "ask if you are married or civil partnered" do
        assert_current_node :married_couple_or_civil_partnership?
      end
      context "answer yes" do
        setup do
          add_response 'yes'
        end
        should "ask where you are now" do
          assert_current_node :where_are_you_now?
        end
        context "answer back in the UK" do
          should "give the oru result" do
            add_response 'in_the_uk'
            assert_equal 'spain', current_state.calculator.registration_country
            assert_current_node :oru_result
            assert_equal "http://www.exteriores.gob.es/Portal/en/ServiciosAlCiudadano/Paginas/Traductoresas---Int%C3%A9rpretes-Juradosas.aspx", current_state.calculator.translator_link_url
          end
        end
      end # married
    end # Spain
  end
  context "answer Afghanistan" do
    setup do
      add_response "afghanistan"
    end

    should "give the ORU result and phase-5-specific intro and custom documents return waiting time" do
      add_response "mother_and_father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_equal 'Afghanistan', current_state.calculator.registration_country_name_lowercase_prefix
      assert_equal 'mother_and_father', current_state.calculator.british_national_parent
      assert_equal '6 months', current_state.calculator.custom_waiting_time
      assert_equal '/government/publications/afghanistan-list-of-lawyers', current_state.calculator.translator_link_url
    end

    should "give the no_birth_certificate_result if the child born outside of marriage" do
      add_response "mother"
      add_response "no"
      add_response "same_country"

      assert_current_node :no_birth_certificate_result
    end
  end

  context "answer Iraq" do
    setup do
      add_response "iraq"
    end

    should "give the no_birth_certificate_result if the child born outside of marriage" do
      add_response "mother"
      add_response "no"
      add_response "same_country"

      assert_current_node :no_birth_certificate_result
    end

    should "give the no_birth_certificate_result if the child born outside of marriage and currently in another country" do
      add_response "mother"
      add_response "no"
      add_response "another_country"

      assert_current_node :no_birth_certificate_result
    end
  end

  context "born in Bangladesh but currently in Pakistan" do
    should "give the ORU result" do
      add_response "bangladesh"
      add_response "mother_and_father"
      add_response "yes"
      add_response "another_country"
      add_response "pakistan"
      assert_current_node :oru_result
      assert_equal '8 months', current_state.calculator.custom_waiting_time
    end
  end # Afghanistan
  context "answer Pakistan" do
    setup do
      add_response "pakistan"
    end

    should "give the oru result if currently in the UK" do
      add_response "father"
      add_response "yes"
      add_response "in_the_uk"
      assert_current_node :oru_result
      assert_equal '6 months', current_state.calculator.custom_waiting_time
    end

    should "give the oru result with phase-5-specific introduction if currently in Pakistan" do
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
    end

    should "give the no_birth_certificate_result if the child born outside of marriage" do
      add_response "mother"
      add_response "no"
      add_response "same_country"

      assert_current_node :no_birth_certificate_result
    end

    should "give the no_birth_certificate_result if the child born outside of marriage and currently in another country" do
      add_response "mother"
      add_response "no"
      add_response "another_country"

      assert_current_node :no_birth_certificate_result
    end
  end # Pakistan

  context "answer Belize" do
    should "give the embassy result" do
      add_response "belize"
      add_response "father"
      add_response "no"
      add_response "2006-07-01"
      add_response "same_country"
      assert_current_node :oru_result
    end # Not married or CP
  end # Belize

  context "answer libya" do
    should "give the no embassy result" do
      add_response "libya"
      assert_current_node :no_embassy_result
    end
  end # Libya

  context 'answer Somalia' do
    should 'give the no embassy result' do
      add_response 'somalia'
      assert_current_node :no_embassy_result
    end
  end # Somalia

  context "answer barbados" do
    should "give the oru result" do
      add_response "barbados"
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_equal 'father', current_state.calculator.british_national_parent
    end # Not married or CP
  end # Barbados
  context "answer united arab emirates" do
    setup do
      add_response "united-arab-emirates"
    end
    should "give the no birth certificate result with same country phrase" do
      add_response "mother_and_father"
      add_response "no"
      add_response "same_country"
      assert_current_node :no_birth_certificate_result
    end # Not married or CP

    should "give the no birth certificate result with another country phrase" do
      add_response "mother_and_father"
      add_response "no"
      add_response "another_country"
      assert_current_node :no_birth_certificate_result
    end # Not married or CP

    should "give the oru result" do
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_equal 'father', current_state.calculator.british_national_parent
      assert_equal '/government/publications/united-arab-emirates-list-of-lawyers', current_state.calculator.translator_link_url
    end
  end # UAE

  context "el-salvador, where you have to register in guatemala" do
    setup do
      add_response "el-salvador"
    end

    should "calculate the registration country as Guatemala" do
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_equal 'guatemala', current_state.calculator.registration_country
      assert_equal 'Guatemala', current_state.calculator.registration_country_name_lowercase_prefix
    end
  end

  context "laos, no longer have to register in thailand" do
    setup do
      add_response "laos"
    end
    should "calculate the registration country as Laos" do
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_equal 'laos', current_state.calculator.registration_country
      assert_equal 'Laos', current_state.calculator.registration_country_name_lowercase_prefix
    end
  end
  context "maldives, where you have to register in sri lanka" do
    setup do
      add_response "maldives"
    end
    should "calculate the registration country as Sri Lanka" do
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_equal 'sri-lanka', current_state.calculator.registration_country
    end
  end
  context "Sri Lanka" do
    setup do
      add_response "sri-lanka"
    end
    should "show a custom documents variant" do
      add_response 'mother'
      add_response 'no'
      add_response 'same_country'

      assert_current_node :oru_result
    end
  end
  context "India" do
    setup do
      add_response "india"
    end
    should "show a custom documents variant" do
      add_response 'mother'
      add_response 'no'
      add_response 'same_country'

      assert_current_node :oru_result
    end
  end
  context "child born in grenada, parent in St kitts" do
    should "calculate the registration country as barbados" do
      add_response 'grenada'
      add_response 'mother'
      add_response 'yes'
      add_response 'another_country'
      add_response 'st-kitts-and-nevis'
      assert_current_node :oru_result
    end
  end

  context "answer Netherlands" do
    should "go to oru result" do
      add_response 'netherlands'
      add_response 'father'
      add_response 'yes'
      add_response 'same_country'
      assert_current_node :oru_result
      assert_equal '/government/publications/netherlands-list-of-lawyers', current_state.calculator.translator_link_url
    end
  end # Netherlands
  context "answer serbia" do
    should "check for clickbook and give embassy result" do
      add_response "serbia"
      add_response "father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_equal '/government/publications/list-of-translators-and-interpreters-in-serbia', current_state.calculator.translator_link_url
    end
  end # Serbia
  context "answer estonia" do
    should "show cash, credit card or cheque condition and give embassy result" do
      add_response "estonia"
      add_response "mother_and_father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
    end
  end # Estonia

  context "answer united-arab-emirates, married" do
    should "go to oru result" do
      add_response "united-arab-emirates"
      add_response "mother_and_father"
      add_response "yes"
      add_response "same_country"
      assert_current_node :oru_result
      assert_equal '/government/publications/united-arab-emirates-list-of-lawyers', current_state.calculator.translator_link_url
    end
  end # UAE

  context "answer oru country and in another country" do
    should "go to oru result" do
      add_response "united-arab-emirates"
      add_response "mother_and_father"
      add_response "yes"
      add_response "another_country"
      add_response "germany"
      assert_current_node :oru_result
    end
  end

  context "answer Morocco and in another country " do
    should "show :oru_result outcome" do
      add_response "morocco"
      add_response "mother_and_father"
      add_response "no"
      add_response "another_country"
      add_response "germany"
      assert_current_node :oru_result
    end
  end

  context "answer Germany and in Cameroon" do
    should "show oru_result outcome" do
      add_response "germany"
      add_response "mother_and_father"
      add_response "no"
      add_response "another_country"
      add_response "cameroon"
      assert_current_node :oru_result
    end
  end

  context "answer Venezuela and still in Venezuela" do
    should "show oru_result outcome" do
      add_response "venezuela"
      add_response "mother_and_father"
      add_response "no"
      add_response "same_country"
      assert_current_node :oru_result
    end
  end

  context "answer Philippines" do
    setup do
      add_response "philippines"
    end

    should "show ORU outcome and require extra documents regardles of the current location" do
      add_response "mother"
      add_response "no"
      add_response "another_country"
      add_response "australia"
      assert_current_node :oru_result
    end

    should "show ORU outcome and require even more extra documents if only the father is british" do
      add_response "father"
      add_response "no"
      add_response "2014-03-04"
      add_response "same_country"
      assert_current_node :oru_result
    end
  end

  context "answer Uganda" do
    should "show ORU outcome and require extra documents" do
      add_response "uganda"
      add_response "mother"
      add_response "no"
      add_response "same_country"
      assert_current_node :oru_result
    end
  end

  context "North Korea" do
    setup do
      add_response "north-korea"
      add_response "mother_and_father"
      add_response "yes"
    end

    should "lead to the North Korea-specific result if the user is still there" do
      add_response "same_country"
      assert_current_node :north_korea_result
    end

    should "lead to the ORU result if in the UK" do
      add_response "in_the_uk"
      assert_current_node :oru_result
    end

    should "lead to the ORU result if in another country" do
      add_response "another_country"
      add_response "netherlands"
      assert_current_node :oru_result
    end
  end

  context "Democratic Republic of Congo" do
    should "lead to an ORU outcome with a custom translator link" do
      add_response "democratic-republic-of-the-congo"
      add_response "mother"
      add_response "no"
      add_response "same_country"
      assert_current_node :oru_result
      assert_equal '/government/publications/democratic-republic-of-congo-list-of-lawyers', current_state.calculator.translator_link_url
    end
  end

  context "Pitcairn Island" do
    should "lead to the ORU result" do
      add_response 'pitcairn-island'
      add_response 'mother'
      add_response 'no'
      add_response 'same_country'
      assert_current_node :oru_result
    end
  end

  context "St Martin" do
    should "lead to the ORU result" do
      add_response 'st-martin'
      add_response 'mother'
      add_response 'no'
      add_response 'same_country'
      assert_current_node :oru_result
    end
  end

  context "Saint Barthelemy" do
    should "lead to the ORU result" do
      add_response 'saint-barthelemy'
      add_response 'mother'
      add_response 'no'
      add_response 'same_country'
      assert_current_node :oru_result
    end
  end

  context "Registration duration" do
    should "display custom duration if child born in a lower risk (non phase-5) country and currently in North Korea" do
      add_response "netherlands"
      add_response "mother"
      add_response "yes"
      add_response "another_country"
      add_response "north-korea"

      assert_current_node :north_korea_result
    end

    should "display 3 months if child born in a lower risk (non phase-5) country and currently in Cambodia" do
      add_response "netherlands"
      add_response "mother"
      add_response "yes"
      add_response "another_country"
      add_response "cambodia"

      assert_current_node :oru_result
    end
  end

  context "ORU payment options" do
    should "display a custom payment message if currently in Algeria" do
      add_response "netherlands"
      add_response "mother"
      add_response "yes"
      add_response "another_country"
      add_response "algeria"
      assert_current_node :oru_result
    end

    should "display a default payment message if currently not in Algeria" do
      add_response "algeria"
      add_response "mother"
      add_response "yes"
      add_response "another_country"
      add_response "netherlands"
      assert_current_node :oru_result
    end

    should "display a default payment message if child was born in Algeria but currently in the UK" do
      add_response "algeria"
      add_response "mother"
      add_response "yes"
      add_response "in_the_uk"
      assert_current_node :oru_result
    end
  end
end
