require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/register-a-death"

class RegisterADeathTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    @location_slugs = %w(afghanistan algeria andorra argentina australia austria barbados belgium brazil cameroon democratic-republic-of-the-congo dominica egypt france germany iran italy kenya libya morocco nigeria north-korea pakistan pitcairn-island poland saint-barthelemy serbia slovakia somalia spain st-kitts-and-nevis st-martin uganda)
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::RegisterADeathFlow
  end

  should "ask where the death happened" do
    assert_current_node :where_did_the_death_happen?
  end

  context "answer England or Wales" do
    setup do
      add_response 'england_wales'
    end
    should "ask whether the death occurred at home or in hospital or elsewhere" do
      assert_current_node :did_the_person_die_at_home_hospital?
    end
    context "answer home or in hospital" do
      setup do
        add_response 'at_home_hospital'
      end
      should "ask if the death was expected" do
        assert_current_node :was_death_expected?
      end
      should "be outcome1 if death was expected" do
        add_response 'yes'
        assert_current_node :uk_result
      end
      should "be outcome3 if death not expected" do
        add_response 'no'
        assert_current_node :uk_result
      end
    end
    context "answer elsewhere" do
      setup do
        add_response 'elsewhere'
      end
      should "ask if the death was expected" do
        assert_current_node :was_death_expected?
      end
      should "be outcome2 if death was expected" do
        add_response :yes
        assert_current_node :uk_result
      end

      should "be outcome4 if death not expected" do
        add_response :no
        assert_current_node :uk_result
      end
    end
  end # England, Wales

  context "answer Scotland" do
    setup do
      add_response 'scotland'
    end
    should "lead to the Scotland result" do
      assert_current_node :scotland_result
    end
  end # Scotland

  context "answer Northern Ireland" do
    setup do
      add_response 'northern_ireland'
    end
    should "lead to the Northern Ireland result" do
      assert_current_node :northern_ireland_result
    end
  end # Northern Ireland

  context "answer overseas" do
    setup do
      add_response 'overseas'
    end

    should "ask which country" do
      assert_current_node :which_country?
    end

    context "Pitcairn Island" do
      should "lead to the ORU result" do
        add_response 'pitcairn-island'
        add_response 'same_country'
        assert_current_node :oru_result
      end
    end

    context "St Martin" do
      should "lead to the ORU result" do
        add_response 'st-martin'
        add_response 'same_country'
        assert_current_node :oru_result
      end
    end

    context "Saint Barthelemy" do
      should "lead to the ORU result" do
        add_response 'saint-barthelemy'
        add_response 'same_country'
        assert_current_node :oru_result
      end
    end

    context "answer Australia" do
      setup do
        add_response 'australia'
      end
      should "give the commonwealth result" do
        assert_equal "Australia", current_state.calculator.registration_country_name_lowercase_prefix
        assert_current_node :commonwealth_result
      end
    end # Australia (commonwealth country)
    context "answer Spain" do
      setup do
        add_response 'spain'
      end
      should "ask where you are now" do
        assert_equal "Spain", current_state.calculator.registration_country_name_lowercase_prefix
        assert_current_node :where_are_you_now?
      end
      context "answer same country" do
        setup do
          add_response 'same_country'
        end
        should "give the embassy result and be done" do
          assert_current_node :oru_result
          assert_equal "http://www.exteriores.gob.es/Portal/en/ServiciosAlCiudadano/Paginas/Traductoresas---Int%C3%A9rpretes-Juradosas.aspx", current_state.calculator.translator_link_url
          assert current_state.calculator.document_return_fees.present?
        end
      end # Answer embassy
      context "answer ORU office in the uk" do
        setup do
          add_response 'in_the_uk'
        end
        should "give the ORU result and be done" do
          assert_current_node :oru_result
          assert_equal "http://www.exteriores.gob.es/Portal/en/ServiciosAlCiudadano/Paginas/Traductoresas---Int%C3%A9rpretes-Juradosas.aspx", current_state.calculator.translator_link_url
        end
      end # Answer ORU
    end # Answer Spain

    context "answer Morocco - currently in the UK" do
      setup do
        add_response 'morocco'
      end
      should "ask where are you now" do
        assert_equal "Morocco", current_state.calculator.registration_country_name_lowercase_prefix
        assert_current_node :where_are_you_now?
      end
      context "answer ORU office in the uk" do
        setup do
          add_response 'in_the_uk'
        end
        should "give the ORU result and be done" do
          assert_current_node :oru_result
          assert_equal "/government/publications/morocco-list-of-lawyers", current_state.calculator.translator_link_url
        end
      end # Answer ORU
    end # Morocco

    context "answer Italy" do
      setup do
        add_response 'italy'
        add_response 'same_country'
      end
      should "give the ORU result and be done" do
        assert_current_node :oru_result
        assert_equal "/government/publications/italy-list-of-lawyers", current_state.calculator.translator_link_url
      end
    end # Answer Italy

    context "death occurred in Andorra, but they are now in France" do
      setup do
        add_response 'andorra'
        add_response 'another_country'
        add_response 'france'
      end
      should "give the oru result and be done" do
        assert_current_node :oru_result
        assert_equal "/government/publications/spain-list-of-lawyers", current_state.calculator.translator_link_url
      end
    end # Answer Andorra, now in France

    context "answer Afghanistan" do
      setup do
        add_response 'afghanistan'
      end
      context "currently still in the country" do
        should "give the oru_result result and a translators link" do
          add_response 'same_country'

          assert_current_node :oru_result
          assert_equal "/government/publications/afghanistan-list-of-lawyers", current_state.calculator.translator_link_url
        end
      end
      context "now back in the UK" do
        should "give the ORU result with a translators link" do
          add_response 'in_the_uk'
          assert_current_node :oru_result
          assert_equal "/government/publications/afghanistan-list-of-lawyers", current_state.calculator.translator_link_url
        end
      end
    end # Answer Afghanistan

    context "answer Algeria" do
      setup do
        add_response 'algeria'
      end

      context "now back in the UK" do
        should "give the ORU result with a translator link and a standard payment method" do
          add_response 'in_the_uk'
          assert_current_node :oru_result
          assert_equal "/government/publications/algeria-list-of-lawyers", current_state.calculator.translator_link_url
        end
      end

      context "now in Algeria" do
        should "give the ORU result with a translator link and a custom payment method" do
          add_response 'another_country'
          add_response 'algeria'
          assert_current_node :oru_result
          assert_equal "/government/publications/algeria-list-of-lawyers", current_state.calculator.translator_link_url
        end
      end
    end # Answer Algeria

    context "answer Iran" do
      setup do
        add_response "iran"
      end

      should "give the oru result for deaths in Iran" do
        add_response "same_country"
        assert_current_node :oru_result
      end

      should "give the oru result for deaths in another country" do
        add_response "another_country"
        add_response "cameroon"
        assert_current_node :oru_result
      end

      should "give the oru result for deaths in the uk" do
        add_response "in_the_uk"
        assert_current_node :oru_result
      end

      should "give the north korean result for deaths in north-korea" do
        add_response "another_country"
        add_response "north-korea"
        assert_current_node :north_korea_result
      end
    end # Iran

    context "answer Libya" do
      setup do
        add_response 'libya'
      end

      should "give the no embassy if currently in Libya" do
        assert_current_node :no_embassy_result
      end
    end # Answer Libya

    context 'answer Somalia' do
      setup do
        add_response 'somalia'
      end

      should 'give the no embassy if currently in Somalia' do
        assert_current_node :no_embassy_result
      end
    end

    context "answer Brazil, registered in north-korea" do
      setup do
        add_response 'brazil'
        add_response 'another_country'
        add_response 'north-korea'
      end
      should "give the north korean result and be done" do
        assert_current_node :north_korea_result
      end
    end # Answer Brazil
    context "Death in Poland, currently in Cameroon" do
      setup do
        add_response 'poland'
        add_response 'another_country'
        add_response 'cameroon'
      end
      should "give the oru result and be done" do
        assert_current_node :oru_result
      end
    end # Answer Poland, currently in Cameroon

    context "answer death in Serbia, user in the UK" do
      setup do
        add_response 'serbia'
        add_response 'in_the_uk'
      end
      should "give the embassy result and be done" do
        assert_equal "/government/publications/list-of-translators-and-interpreters-in-serbia", current_state.calculator.translator_link_url
      end
    end # Answer Serbia
    context "answer Pakistan, user in the UK" do
      should "give the oru result" do
        add_response "pakistan"
        add_response "in_the_uk"
        assert_current_node :oru_result
      end
    end # Pakistan and in UK
    context "answer death in dominica, user in st kitts" do
      setup do
        add_response 'dominica'
        add_response 'another_country'
        add_response 'st-kitts-and-nevis'
      end
      should "give the embassy result and be done" do
        assert_nil current_state.calculator.translator_link_url
      end
    end # Answer Dominica
    context "answer death in Egypt, user in Belgium" do
      setup do
        add_response 'egypt'
        add_response 'another_country'
        add_response 'belgium'
      end
      should "give oru_result" do
        assert_current_node :oru_result
        assert_equal 'Egypt', current_state.calculator.death_country_name_lowercase_prefix
        assert_equal "Belgium", current_state.calculator.registration_country_name_lowercase_prefix
        assert_equal 'belgium', current_state.calculator.registration_country
      end
    end # Death in Egypt user in Belgium

    context "answer North Korea" do
      setup do
        add_response 'north-korea'
      end
      context "still in North Korea" do
        should "give the North Korea-specific result" do
          add_response 'same_country'
          assert_current_node :north_korea_result
        end
      end
      context "in another country" do
        should "give the ORU result" do
          add_response 'another_country'
          add_response 'italy'
          assert_current_node :oru_result
        end
      end
    end # Answer North Korea

    context "died in austria, user in north-korea" do
      setup do
        add_response 'austria'
        add_response 'another_country'
        add_response 'north-korea'
      end
      should "take you to the embassy outcome with specific phrasing" do
        assert_current_node :north_korea_result
      end
    end

    context "death in Kenya, now in the UK" do
      setup do
        add_response 'kenya'
        add_response 'in_the_uk'
      end

      should "take you to the ORU outcome with custom courier message without common text" do
        assert_current_node :oru_result
      end
    end

    context "death in Nigeria, now in the UK" do
      setup do
        add_response 'nigeria'
        add_response 'in_the_uk'
      end

      should "take you to the ORU outcome with custom courier message without common text" do
        assert_current_node :oru_result
      end
    end

    context "death in Uganda, now in the UK" do
      setup do
        add_response 'uganda'
        add_response 'in_the_uk'
      end

      should "take you to the embassy outcome with custom courier message" do
        assert_current_node :oru_result
      end
    end

    context "Democratic Republic of Congo" do
      should "lead to an ORU outcome with a custom translator link" do
        add_response "democratic-republic-of-the-congo"
        add_response "in_the_uk"
        assert_current_node :oru_result
        assert_equal '/government/publications/democratic-republic-of-congo-list-of-lawyers', current_state.calculator.translator_link_url
      end
    end
  end # Overseas
end
