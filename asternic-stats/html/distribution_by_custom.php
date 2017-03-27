<?php
// Distribution calls by custom field
// In the report designer you have to add JOIN_TABLE keywords to add custom fields
// Here is an example for using the info5 field for the ENTERQUEUE event on reports
//
// keyword: JOIN_TABLE
// parameter: q2.info5 AS MyField
// value:
//
// You can add foreing data by joining to some other table, in that case
// set value to the JOIN line for an SQL query
//
// Then you must add that data in a column for reports, for example:
//
// keyword: COLUMN_UNANSWERED
// parameter: MyField
// value: CUSTOM_MYFIELD
//
// For data in columns, any added field is named CUSTOM_(UPPERCASENAME)
//
// With that in place, you can have that column in detailed distribution reports. 
// If the value is numeric, you can use MAX_, MIN_, etc, in formulas
//
// Finally you can add a group report like this one, and add it to the list of
// distribution_reports in the Designer

$resource = basename(__FILE__);
if( check_acl($resource)) {
    call_distribution($resdis,'HTML','MyField');
}
