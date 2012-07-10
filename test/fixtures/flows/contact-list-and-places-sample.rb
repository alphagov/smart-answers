status :draft

multiple_choice :what_are_you_testing? do
  option :contact_list => :done_contact_list
  option :places => :done_places
  calculate :sample_contacts do
    [
      {
        "address" => "British High Commission\r\nConsular Section\r\nCommonwealth Avenue\r\nYarralumla\r\nACT 2600,",
        "phone" => "(+61) (0) 2 6270 6666",
      },
      {
        "address" => "444-446 Pulteney Street\r\nAdelaide\r\nSA 5000\r\n,Adelaide",
        "phone" => "",
      },
      {
        "address" => "British High Commission\r\nWellington\r\n44 Hill Street\r\nWellington 6011\r\n\r\nMailing Address:\r\nP O Box 1812\r\nWellington 6140,Wellington",
        "phone" => "(+64) (0) 9 6270 1234",
      },
    ]
  end
end

outcome :done_contact_list do
  contact_list :sample_contacts
end

outcome :done_places
