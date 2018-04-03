#!/bin/sh

COUNTRY="$1"

COUNTRIES="lib/smart_answer_flows/marriage-abroad/outcomes/countries"
COUNTRY_PARTIALS="$COUNTRIES/$COUNTRY"

rm -rf "$COUNTRY_PARTIALS"

cp -r "test/artefacts/marriage-abroad/$COUNTRY" "$COUNTRY_PARTIALS"

read -r -d '' FEE_TABLE_PARTIAL << END
<%= render partial: 'consular_fees_table_items.govspeak.erb',
    collection: calculator.services,
    as: :service,
    locals: { calculator: calculator } %>
END

FEE_TABLE_PARTIAL_WITH_LITERAL_NEWLINES="${FEE_TABLE_PARTIAL//$'\n'/\\n}\\n"

read -r -d '' HOW_TO_PAY_PARTIAL << END
<%= render partial: 'how_to_pay.govspeak.erb', locals: {calculator: calculator} %>\n
END

for file in $(find $COUNTRIES/$COUNTRY/*/ -type f)
do
    OLD_NAME="$file"

    NEW_NAME="${OLD_NAME/txt/erb}"
    NEW_NAME="${NEW_NAME/same_sex/_same_sex}"
    NEW_NAME="${NEW_NAME/opposite_sex/_opposite_sex}"

    mv "$OLD_NAME" "$NEW_NAME"

    echo "Stripping top two lines"
    sed -i -e 1,2d "$NEW_NAME"

    echo "Replacing how to pay with partial in ${file/$COUNTRIES\//}"
    perl -0777 -i -pe \
         "s/^\^?You can( only)? pay by.*?\n.*?^$/${HOW_TO_PAY_PARTIAL}/migs" \
         "$NEW_NAME"

    echo "Replacing Fees table with fees partial in ${file/$COUNTRIES\//}"
    perl -0777 -i -pe \
         "s/^Service \| Fee\n.*?^$/${FEE_TABLE_PARTIAL_WITH_LITERAL_NEWLINES}/migs" \
         "$NEW_NAME"
done
