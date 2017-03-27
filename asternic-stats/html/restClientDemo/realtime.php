<?php
/*
Demo on getting realtime queue status using your own PHP script 
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
$final_uri .= "/rest/index.php?entity=realtime";
$url        = $server."/".$final_uri;
//$url = "http://www.google.com";
// set context to add http authentication data
$context = stream_context_create(array(
    'http' => array(
        'header'  => "Authorization: Basic " . base64_encode("$username:$password")
    )
));

// retrieve the JSON data for realtime status as associative array
$data = json_decode(file_get_contents($url, false, $context), true);

//$data = file_get_contents($url, false, $context);
//print_r($data);

if($data=="") {
   echo "<h1>No data, probably wrong credentials.</h1>";
}
// echo "<pre>";
// print_r($data);

foreach($data['summary']['queue'] as $queue => $datarray) {

   //  [staffed] => 2
   //  [talking] => 0
   //  [auxiliary] => 2
   //  [answeredCals] => 0
   //  [unansweredCalls] => 0
   //  [abandonRate] =>  0
   //  [averageWaitTime] => 0
   //  [averageCallTime] => 00:00:00
   //  [callsWaiting] => 1
   //  [maxWaitTime] => 509

   echo "<h1>Queue $queue</h1>";
   echo "Calls Waiting: ".$datarray['Waiting']."<br/>";
   echo "Maximum Waiting Time: ".$datarray['maxWaitTime']." seconds<br/>";
   if($datarray['Waiting']>0) {
       echo "<ul>";
       foreach($data['waiting calls'][$queue] as $pos=>$callarray) {
           echo "<li>$pos: ".$callarray['calleridNum']." (".$callarray['waitTime'].") seconds</li>";
           
       }
       echo "</ul>";
   }
   echo "<hr/>";
}


