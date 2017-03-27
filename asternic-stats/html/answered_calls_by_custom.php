<?php
// Answered calls by custom field
// In the report designer you have to add JOIN_TABLE keywords to add custom fields
// Here is an example for using the info5 field for the ENTERQUEUE event on reports
//
// keyword: JOIN_TABLE
// parameter: q2.info5 AS MyField
// value:
//
// Then you must add that data in a column for reports, for example:
//
// keyword: COLUMN_ANSWERED
// parameter: MyField
// value: CUSTOM_MYFIELD
//
// For data in columns, any added field is named CUSTOM_(UPPERCASENAME)
//
// With that in place, you can have that column in detailed answered reports. 
// If the value is numeric, you can use MAX_, MIN_, etc, in formulas
//
// Finally you can add a group report like this one, and add it to the list of
// answered_reports in the Designer

$resource = basename(__FILE__);
if( check_acl($resource)) {
    answered_calls($resans,'HTML','MyField');
}
