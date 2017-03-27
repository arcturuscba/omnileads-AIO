<?php
/*
Demo on getting call distribution report for today using your own PHP script 
and the REST interface in Asternic
*/

// Asternic user and password to access the reports
$username = "admin";
$password = "admin";

// Construct the complete URL to obtain
// http://server/asternic/rest/index.php?entity=realtime
//
if(isset($_SERVER['HTTPS'])) {
   $server = "https://".$_SERVER['HTTP_HOST'];
} else {
   $server = "http://".$_SERVER['HTTP_HOST'];
}
$partes = preg_split("|/|",$_SERVER['REQUEST_URI']);
array_pop($partes);
array_pop($partes);
$final_uri  = join("/",$partes);
$final_uri .= "/rest/index.php?entity=reports/distribution_by_queue";
//$final_uri .= "/rest/index.php?entity=realtime";
$url        = $server."/".$final_uri;

// set context to add http authentication data
$context = stream_context_create(array(
    'http' => array(
        'header'  => "Authorization: Basic " . base64_encode("$username:$password")
    )
));

// retrieve the JSON data for realtime status as associative array
$data = json_decode(file_get_contents($url, false, $context), true);

if($data=="") {
   echo "<h1>No data, probably wrong credentials.</h1>";
}
echo "<pre>";
print_r($data);
echo "</pre>";


