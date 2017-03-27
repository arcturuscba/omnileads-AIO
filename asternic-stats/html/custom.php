<?php
function test_format($valor,$base=5) {
    $valores_return = Array();
    $width1 = 16 * $base;
    $valores[] = $base;
    $valores[] = $valor;
    $width2 = min($valores) * 16;
    $valores_return[] = "<span class='stars helptop' title='$valor' style='width: ${width1}px'><span style='width: ${width2}px'></span></span>";
    $valores_return[] = $valor;
    return $valores_return;
}

function encuesta_format($valor) {
    $valores_return = Array();
    if($valor==1) {
        $valores_return[] = "<span class='label label-success'><i class='icon-star icon-white'></i></span>";
    } else if($valor==2) {
        $valores_return[] = "<span class='label label-important'><i class='icon-star icon-white'></i></span>";
    } else {
        $valores_return[] = "<i class='icon-star-empty'></i>";
    }
    $valores_return[] = $valor;
    return $valores_return;
}

function realtime_clidnum_filter($clid) {
    return $clid;
}

function realtime_clidname_filter($clidname) {
    return $clidname;
}
