function ratecall(uni,file) {
   alert(uni);
}

function DivCreate(uni,file){
if($("#dialograte").length == 0){
var objeto="<div id='grabacrate'><object type='application/x-shockwave-flash' data='mp3player.swf' width='390' height='24'><param name='movie' value='mp3player.swf' /><param name='FlashVars' value='playerID=1&autostart=yes&soundFile=download.php?file="+file+"'></object></div>";
$("#xdistribution_detail").append("<div id='dialograte' title='Call Rating'>"+objeto+"<br>/usr/src/asternic-stats-pro-1.5-gtel/html/recordings/"+file+"</div>");
$("#dialograte").dialog({height:500,width:500,modal:true,buttons:{Ok:function(){$( this ).dialog("close"); }}});
}else{$("#dialograte").dialog("open");}
if(file.length == 0){$("#grabacrate").hide();}else{$("#grabacrate").show();}
}
