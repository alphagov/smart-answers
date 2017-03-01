require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/overseas-passports"

class OverseasPassportsTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    @location_slugs = %w(albania algeria afghanistan australia austria azerbaijan bahamas bangladesh benin british-indian-ocean-territory burma burundi cambodia cameroon china congo democratic-republic-of-the-congo georgia greece haiti hong-kong india iran iraq ireland italy jamaica jordan kenya kyrgyzstan laos malta nepal nigeria pakistan pitcairn-island saint-barthelemy saudi-arabia syria south-africa spain sri-lanka st-helena-ascension-and-tristan-da-cunha st-maarten st-martin tajikistan tanzania timor-leste turkey turkmenistan ukraine united-kingdom united-arab-emirates usa uzbekistan yemen zimbabwe venezuela vietnam zambia)
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::OverseasPassportsFlow
  end

  ## Q1
  should "ask which country you are in" do
    assert_current_node :which_country_are_you_in?
  end

  # Afghanistan (An example of bespoke application process).
  context "answer Afghanistan" do
    setup do
      add_response 'afghanistan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          add_response 'afghanistan'
          assert_current_node :ips_application_result
        end
      end
    end

    context "answer renewing" do
      setup do
        add_response 'renewing_new'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_current_node :ips_application_result
        end
      end
    end

    context "answer lost or stolen" do
      setup do
        add_response 'replacing'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_current_node :ips_application_result
        end
      end
    end
  end # Afghanistan

  # Iraq (An example of ips 1 application with some conditional phrases).
  context "answer Iraq" do
    setup do
      add_response 'iraq'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask the country of birth" do
          assert_current_node :country_of_birth?
        end
        context "answer UK" do
          setup do
            add_response 'united-kingdom'
          end
          should "give the result and be done" do
            assert_current_node :ips_application_result
            assert_match(/Freeman’s Reach/, outcome_body)
          end
        end
      end
    end
  end # Iraq

  context "answer Benin, renewing old passport" do
    setup do
      add_response 'benin'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
    end
    should "give the result with alternative embassy details" do
      assert_current_node :ips_application_result
    end
  end

  # Austria (An example of IPS application 1).
  context "answer Austria" do
    setup do
      add_response 'austria'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "give the result and be done" do
          assert_current_node :country_of_birth?
        end
        context "answer Greece" do
          setup do
            add_response 'greece'
          end

          should "give the result" do
            assert_current_node :ips_application_result_online
          end
        end
      end
    end # Applying

    context "answer renewing old blue or black passport" do
      setup do
        add_response 'renewing_old'
        add_response 'adult'
      end
      should "ask which country you were born in" do
        assert_current_node :country_of_birth?
      end
    end # Renewing old style passport
    context "answer replacing" do
      setup do
        add_response 'replacing'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_current_node :ips_application_result_online
        end
      end
    end # Replacing
  end # Austria - IPS_application_1

  context "answer Spain, an example of online application, doc group 1" do
    setup do
      add_response 'spain'
    end
    should "show how to apply online" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_match(/the passport numbers of both parents/, outcome_body)
    end
    should "show how to replace your passport online" do
      add_response 'replacing'
      add_response 'child'
      assert_current_node :ips_application_result_online
    end
  end

  context "answer Greece, an example of online application, doc group 2" do
    setup do
      add_response 'greece'
    end
    should "show how to apply online" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result_online
    end
    should "show how to replace your passport online" do
      add_response 'replacing'
      add_response 'child'
      assert_current_node :ips_application_result_online
    end
  end

  context "answer Vietnam, an example of in person application, doc group 1" do
    setup do
      add_response 'vietnam'
    end
    should "show how to apply in person" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
  end

  # Albania (an example of IPS application 2).
  context "answer Albania" do
    setup do
      add_response 'albania'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask which country you were born in" do
          assert_current_node :country_of_birth?
        end
        context "answer Spain" do
          should "give the application result" do
            add_response "spain"
            assert_current_node :ips_application_result_online
          end
        end
        context "answer UK" do
          should "give the application result" do
            add_response "united-kingdom"
            assert_current_node :ips_application_result_online
          end
        end
      end
    end # Applying
  end # Albania - IPS_application_2

  # Ajerbaijan (an example of IPS application 3 and UK Visa centre).
  context "answer Azerbaijan" do
    setup do
      add_response 'azerbaijan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
    end
    context "answer replacing adult passport" do
      setup do
        add_response 'replacing'
        add_response 'adult'
      end
      should "give the IPS application result" do
        assert_current_node :ips_application_result
      end
    end # Applying
  end # Azerbaijan - IPS_application_3

  # Burundi (An example of IPS 3 application with some conditional phrases).
  context "answer Burundi" do
    setup do
      add_response 'burundi'
    end

    should "give the correct result when renewing new style passport" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
    end

    should "give the correct result when renewing old style passport" do
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
    end

    should "give the correct result when applying for the first time" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
    end

    should "give the correct result when replacing lost or stolen passport" do
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
  end # Burundi

  context "answer Ireland, replacement, adult passport" do
    should "give the ips online application result" do
      add_response 'ireland'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result_online
    end
  end # Ireland (FCO with custom phrases)

  context "answer India" do
    setup do
      add_response 'india'
    end
    context "applying, adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'india'
        assert_current_node :ips_application_result
      end
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
  end # India

  context "answer Tanzania, replacement, adult passport" do
    should "give the ips online result with custom phrases" do
      add_response 'tanzania'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
    end
  end # Tanzania

  context "answer Congo, replacement, adult passport" do
    should "give the result with custom phrases" do
      add_response 'congo'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
    end
  end # Congo

  context "answer Democratic Republic of the Congo, replacement, adult passport" do
    should "give the result with custom phrases" do
      add_response 'democratic-republic-of-the-congo'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
    end
  end # Congo

  context "answer Malta, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      add_response 'malta'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result_online
    end
  end # Malta (IPS1 with custom phrases)

  context "answer Italy, replacement, adult passport" do
    should "give the IPS online result" do
      add_response 'italy'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result_online
    end
  end # Italy (IPS online result)

  context "answer Jordan, replacement, adult passport" do
    should "give the ips1 result with custom phrases" do
      add_response 'jordan'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_match(/Freeman’s Reach/, outcome_body)
    end
  end # Jordan (IPS1 with custom phrases)

  context "answer Pitcairn Island, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      add_response 'pitcairn-island'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
    end
  end # Pitcairn Island (IPS1 with custom phrases)

  context "answer Ukraine, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      add_response 'ukraine'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
    end
  end # Ukraine (IPS3 with custom phrases)

  context "answer Ukraine, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      add_response 'ukraine'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
  end # Ukraine (IPS3 with custom phrases)

  context "answer nepal, renewing new, adult passport" do
    should "give the IPS application result with custom phrases" do
      add_response 'nepal'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
  end # nepal (IPS3 with custom phrases)

  context "answer nepal, lost or stolen, adult passport" do
    should "give the IPS application result with custom phrases" do
      add_response 'nepal'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
  end # nepal (IPS1 with custom phrases)

  context "answer Yemen" do
    should "give an outcome stating an application is not possible in Yemen" do
      add_response 'yemen'
      assert_current_node :apply_in_neighbouring_country
    end
  end # Yemen - no application outcome

  context "answer Iran" do
    should "give an outcome stating an application is not possible in Iran" do
      add_response 'iran'
      assert_current_node :apply_in_neighbouring_country
    end
  end # Iran - no application outcome

  context "answer Syria" do
    should "give an outcome stating an application is not possible in Syria" do
      add_response 'syria'
      assert_current_node :apply_in_neighbouring_country
    end
  end # Syria - no application outcome

  context "answer Cameroon, renewing, adult passport" do
    should "give the generic result with custom phrases" do
      add_response 'cameroon'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_match(/Freeman’s Reach/, outcome_body)
    end
  end # Cameroon (custom phrases)

  context "answer Kenya, applying, adult passport" do
    should "give the generic result with custom phrases" do
      add_response 'kenya'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_match(/Freeman’s Reach/, outcome_body)
    end
  end # Kenya (custom phrases)

  context "answer Kenya, renewing_old, adult passport" do
    should "give the generic result with custom phrases" do
      add_response 'kenya'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_match(/Freeman’s Reach/, outcome_body)
    end
  end # Kenya (custom phrases)

  context "answer Haiti, renewing new, adult passport" do
    should "give the ips result" do
      add_response 'haiti'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result_online
    end
  end # Haiti

  context "answer South Africa" do
    context "applying, adult passport" do
      should "give the IPS online result" do
        add_response 'south-africa'
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result_online
      end
    end
    context "renewing, adult passport" do
      should "give the IPS online result" do
        add_response 'south-africa'
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result_online
      end
    end
  end # South Africa (IPS online application)

  context "answer St Helena etc, renewing old, adult passport" do
    setup do
    end
    should "give the ips application result for renewing_old" do
      add_response 'st-helena-ascension-and-tristan-da-cunha'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'st-helena-ascension-and-tristan-da-cunha'
      assert_current_node :ips_application_result
    end
    should "give the ips application result for renewing_new" do
      add_response 'st-helena-ascension-and-tristan-da-cunha'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
  end # St Helena

  context "answer Nigeria, applying, adult passport" do
    should "give the result with custom phrases" do
      add_response 'nigeria'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
    end
  end # Nigeria

  context "answer Jamaica, replacement, adult passport" do
    should "give the ips result with custom phrase" do
      add_response 'jamaica'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_match(/Freeman’s Reach/, outcome_body)
    end
  end # Jamaica

  context "answer Zimbabwe, applying, adult passport" do
    setup do
      add_response 'zimbabwe'
    end
    should "give the ips outcome with applying phrases" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
    end
    should "give the ips outcome with renewing_new phrases" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
    should "give the ips outcome with replacing phrases" do
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
  end # Zimbabwe

  context "answer Bangladesh" do
    setup do
      add_response 'bangladesh'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "replacing a new adult passport" do
      should "give the ips result" do
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'bangladesh'
        assert_current_node :ips_application_result
      end
    end
  end # Bangladesh

  context "answer Tajikistan" do
    context "renewing a new adult passport" do
      setup do
        add_response 'tajikistan'
        add_response 'renewing_new'
        add_response 'adult'
      end
      should "give the correct ips result" do
        assert_current_node :ips_application_result
      end
    end
  end

  context "answer Turkmenistan" do
    context "renewing a new adult passport" do
      setup do
        add_response 'turkmenistan'
        add_response 'renewing_new'
        add_response 'adult'
      end
      should "give the ips result" do
        assert_current_node :ips_application_result
      end
    end
    context "applying for a new adult passport" do
      setup do
        add_response 'turkmenistan'
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
      end
      should "give the ips result" do
        assert_current_node :ips_application_result
      end
    end
    context "replacing a lost or stolen passport for a child" do
      setup do
        add_response 'turkmenistan'
        add_response 'replacing'
        add_response 'child'
      end
      should "give the specific reference to embassy location" do
        assert_current_node :ips_application_result
      end
    end
  end # Turkmenistan

  context "answer Uzbekistan" do
    setup do
      add_response 'uzbekistan'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
      end
    end
    context "replacing a lost or stolen passport for a child" do
      should "give the specific reference to embassy location" do
        add_response 'replacing'
        add_response 'child'
        assert_current_node :ips_application_result
      end
    end
  end # Uzbekistan

  context "answer Bahamas, applying, adult passport" do
    should "give the IPS online outcome" do
      add_response 'bahamas'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
    end
  end # Bahamas

  context "answer british-indian-ocean-territory" do
    should "go to apply_in_neighbouring_country outcome" do
      add_response 'british-indian-ocean-territory'
      assert_current_node :apply_in_neighbouring_country
    end
  end # british-indian-ocean-territory

  context "answer turkey, doc group 2" do
    setup do
      add_response 'turkey'
    end
    should "show how to apply online" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_match(/the passport numbers of both parents/, outcome_body)
    end
  end

  context "answer Algeria" do
    setup do
      add_response 'algeria'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
      end
    end
  end # Algeria

  context "answer Burma" do
    setup do
      add_response 'burma'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
      end
    end
  end # Burma

  context "answer Cambodia, testing getting your passport" do
    setup do
      add_response 'cambodia'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
      end
    end
  end # Cambodia

  context "answer Kyrgyzstan" do
    should "give ips_application_result outcome with correct UK Visa centre address" do
      add_response 'kyrgyzstan'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
    end
  end # Kyrgyzstan

  context "answer Georgia, testing for ips2 courier costs" do
    should "give the IPS outcome" do
      add_response 'georgia'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
    end
  end # Georgia

  context "answer Timor-Leste, testing sending application" do
    setup do
      add_response 'timor-leste'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
      end
    end
  end # Timor-Leste

  context "answer Venezuela, UK Visa Application Centre" do
    setup do
      add_response 'venezuela'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
      end
    end
  end # Venezuela
  #australia
  context "answer australia, test time phrase" do
    setup do
      add_response 'australia'
    end
    context "applying for an adult passport" do
      should "be 8 weeks" do
        add_response 'applying'
        add_response 'adult'
        add_response 'afghanistan'
        assert_current_node :ips_application_result_online
      end
    end
    context "replacing an adult passport" do
      should "be 8 weeks" do
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :ips_application_result_online
      end
    end
  end
  #china
  context "answer china, test time phrase" do
    setup do
      add_response 'china'
    end
    context "renewing a new adult passport" do
      should "be 6 weeks" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end
    context "renewing an old adult passport" do
      should "be 8 weeks" do
        add_response 'renewing_old'
        add_response 'adult'
        add_response 'afghanistan'
        assert_current_node :ips_application_result
      end
    end
  end
  # Testing for Pakistan
  context "testing for pakistan outcome variations" do
    setup do
      add_response 'pakistan'
    end
    context "renewing_new pakistan adult passport" do
      should "go to outcome with correct phrases" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end # renewing_new adult
    context "replacing adult passport" do
      should "give the ips result" do
        add_response 'replacing'
        add_response 'child'
        assert_current_node :ips_application_result
      end
    end # replacing child
  end # Pakistan tests

  context "test for Hong-Kong" do
    setup do
      add_response 'hong-kong'
    end
    context "renewing_new adult" do
      should "show correct Hong Kong ID phrase" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result_online
      end
    end
  end

  context "test for Laos" do
    setup do
      add_response 'laos'
    end

    context "renewing_new adult" do
      should "have custom phrase for send_application_uk_visa_renew_new_colour_laos" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end

    context "replacing adult" do
      should "have custom phrase for send_application_uk_visa_renew_new_colour_laos" do
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :ips_application_result
      end
    end

    context "renewing_old adult" do
      should "have custom phrase for send_application_uk_visa_renew_new_colour_laos" do
        add_response 'renewing_old'
        add_response 'adult'
        add_response 'laos'

        assert_current_node :ips_application_result
      end
    end

    context "applying adult" do
      should "have custom phrase for send_application_uk_visa_renew_new_colour_laos" do
        add_response 'applying'
        add_response 'adult'
        add_response 'laos'

        assert_current_node :ips_application_result
      end
    end
  end

  context "Saint Barthelemy" do
    should "suggest to apply online" do
      add_response 'saint-barthelemy'
      add_response 'renewing_new'
      add_response 'adult'

      assert_current_node :ips_application_result_online
    end
  end

  context "St Martin (same as St Maarten)" do
    should "suggest to apply online" do
      add_response 'st-martin'
      add_response 'renewing_new'
      add_response 'adult'

      assert_current_node :ips_application_result_online
    end
  end

  context "St Maarten (same as St Martin)" do
    should "suggest to apply online" do
      add_response 'st-maarten'
      add_response 'renewing_new'
      add_response 'adult'

      assert_current_node :ips_application_result_online
    end
  end
end
