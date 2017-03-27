<?php
/*
Demo on getting realtime queue status using your own PHP script 
and the REST interface in Asternic
*/
// Asternic user and password to access the reports
require_once("../config.php");
require_once("../firstin.php");
require_once("../misc.php");



$companyimage="../images/asternic_logo.png";///logo image of your company
$username = "admin";/// Call Center Stats username for login to REST web service
$password = "admin";/// password for username
$version  = "2"; /// Call Center Stats PRO version (just 1 or 2)
$backgroundcolor = "f7f1d7";//// background color of page
$refreshseconds = 5;//// refresh page every 'this' seconds



/////styles for status at Agents table
$stylearray['not in use']="style='background-color:#70ad47;color:#fff;'";///////waiting state
$stylearray['busy']="style='background-color:#c00000;color:#fff;'";
$stylearray['ringing']="style='background-color:#00ff00;'";
$stylearray['dialout']=$stylearray['busy'];
$stylearray['paused']="style='background-color:#ffc000;'";
$stylearray['busy with pause']="style='background-color:#ff76b6;'";

//////styles for waiting cells on queues summary
$waitingstyle[1]="style='background-color:#ffff00;'";
$waitingstyle[2]=$waitingstyle[1];
$waitingstyle[3]=$waitingstyle[1];
$waitingstyle[4]="style='background-color:#ed7d31;'";
$waitingstyle[5]=$waitingstyle[4];
$waitingstyle[6]=$waitingstyle[4];
$waitingstyle[7]="style='background-color:#c00000;'";




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


$qage="<table width='100%' class='agents'><tr><th width='33%'>Qname</th><th width='33%'>Agent Name</th><th width='33%'>Status</th></tr>";
foreach($data['agents'] as $queues => $agentsarray){
	foreach($agentsarray as $name => $dataagent){
		if($dataagent['paused']=='1' && $dataagent['status']=='not in use'){$estado='paused';}elseif($dataagent['paused']=='1' && ($dataagent['status']=='busy'||$dataagent['status']=='dialout')){$estado='busy with pause';}else{$estado=$dataagent['status'];}
		if($version=='2'){
		$qage.="<tr><td>".$queues."</td><td>".$name."</td><td ".$stylearray[$estado].">".$estado."</td></tr>";
		}else{
		$qage.="<tr><td>".$queues."</td><td>".$name."</td><td ".$stylearray[$estado].">".$estado."</td></tr>";
		}
	}
	$qage.="<tr><td colspan='3'>&nbsp;</td></tr>";
}
$qage.="</table>";






$qsum="<table width='100%' class='queues'><tr><th width='33%'>Qname</th><th width='33%'>Agents</th><th width='33%'>Waiting</th></tr>";
foreach($data['summary']['queue'] as $queue => $datarray) {
if($version=='2'){
$qsum.="<tr><td>".queue_name($queue)."</td><td>".$datarray['Agents']."</td><td ".($datarray['Waiting']>7?$waitingstyle[7]:$waitingstyle[$datarray['Waiting']])." >".$datarray['Waiting']."</td></tr>";
}else{
$qsum.="<tr><td>".queue_name($queue)."</td><td>".$datarray['staffed']."</td><td ".($datarray['callsWaiting']>7?$waitingstyle[7]:$waitingstyle[$datarray['callsWaiting']])." >".$datarray['callsWaiting']."</td></tr>";
}
}
$qsum.="</table>";
?>
<html>
<head>
<meta http-equiv="refresh" content="<?php echo $refreshseconds; ?>">
<style>
.queues {  }
.queues th { font-size:25px; }
.agents th { font-size:25px; }
.queues td { font-size:20px; border-style:solid; border-width:1px; }
.agents td { font-size:20px; border-style:solid; border-width:1px; }
</style>
</head>
<body bgcolor="#<?php echo $backgroundcolor; ?>">

<center><img src="<?php echo $companyimage; ?>"></center>
<br><br><br>
<?php

echo $qsum."<br><br>".$qage;
