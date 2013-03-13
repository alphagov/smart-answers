# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class FindABritishEmbassyTest < ActiveSupport::TestCase
  include FlowTestHelper
  
  setup do
    setup_for_testing_flow 'find-a-british-embassy'
  end

  should "ask which country you want details for" do
    assert_current_node :choose_embassy_country
  end

  context "details in afghanistan" do
    setup do
      add_response 'afghanistan'
    end
    should "go to outcome" do
      assert_current_node :embassy_outcome
      assert_state_variable :embassy_details, "\n\n\n$A\n  British Embassy\n15th Street, Roundabout Wazir Akbar Khan\nPO Box 334\nKabul\nAfghanistan,Kabul\n$A\n\n$C\n  britishembassy.kabul@fco.gov.uk\n\n  +93 (0) 700 102 000\n\n  0830-1630 (Sunday to Thursday)\n$C\n"
    end
  end
  context "details in brazil" do
    setup do
      add_response 'brazil'
    end
    should "go to outcome" do
      assert_current_node :embassy_outcome
      assert_state_variable :embassy_details, "Brasilia


$A
  British Embassy 
Setor de Embaixadas Sul 
Quadra 801, Lote 8 
CEP 70408-900 
Brasilia - DF, Brazil
$A

$C
  

  (55) (61) 3329-2300

  GMT:
Mon-Thurs: 1130-1945 (lunch break: 1530-1630)
Fri: 1130 - 1930 (lunch break: 1530-1630)

Local Time:
Mon-Thurs: 0830 - 1645 (lunch break: 1230-1330) 
Friday: 0830 - 1630 (lunch break: 1230-1330)
$C
Rio de Janeiro


$A
  British Consulate-General
Praia do Flamengo 284/2 andar
22210-030
Rio de Janeiro RJ
$A

$C
  

  (55) (21) 2555 9600 
(55) (21) 2555 9640

  GMT:
Mon-Thurs: 1130-1945
Fri: 1130-1530
Local Time:
Mon-Thurs: 0830-1645
Fri: 0830-1630

Opening hours (open to the public): Monday to Friday: 08:30 to 12:30
$C
Sao Paulo


$A
  British Consulate-General
Rua Ferreira de Araujo, 741 - 2 Andar
Pinheiros
05428-002
Sao Paulo-SP
$A

$C
  

  (55) (11) 3094 2700

  GMT:
Mon-Fri: 1030-1900

Local Time:
Mon-Fri: 0830-1700
Opening hours (open to the public): Monday to Friday: 08:30 to 12:30
$C
"
    end
  end

end
