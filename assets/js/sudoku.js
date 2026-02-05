// { 
//     "cells": [
//         {
//         "num" : 0,
//         "possibles" : [1,2,3,4,5,6,7,8,9]
//     },
//     {
//         "num" : 0,
//         "possibles" : [1,2,3,4,5,6,7,8,9]
//     } 
//  ]   
// }

let ws
let innercell = `<table id="gridi">
<tr>
<td id="cell-i1">1</td>
<td id="cell-i2">2</td>
<td id="cell-i3">3</td>
</tr>
<tr>
<td id="cell-i4">4</td>
<td id="cell-i5">5</td>
<td id="cell-i6">6</td>
</tr>
<tr>
<td id="cell-i7">7</td>
<td id="cell-i8">8</td>
<td id="cell-i9">9</td>
</tr>
</table>`
let createWs = function (){
  ws = new WebSocket("ws://localhost:8080/ws")
  console.log("initialized websocket")
  //while (ws.readyState !== 1);
  ws.onopen = function(evt) {
    console.log(evt.type)
    console.log("connected");
  }
  ws.onclose = function() {
    console.log("closed websocket")
    ws.send("close")
    ws.close()
  }
  ws.onmessage = function(evt) {  
    messageHandler(evt)
  }
}

function messageHandler(evt){
 //console.log(evt).toString() //data: '[{"type":"grid"},{"num":"5300700006001950000980000…3400803001700020006060000280000419005000080079"}]'
 const d = JSON.parse(evt.data) 
 console.log(d[0].type)
  switch (d[0].type){
    case 'grid':   
      const n = d[1].num.toString()     
      for (var i = 0; i < n.length; i++) {
        const e = document.getElementById("cell-" + i.toString())
        console.log("cell-" + i.toString())
        if(n[i] === '0'){
          e.innerHTML = innercell
          e.disabled = false
        }
        else{
        	e.innerHTML=n[i]
        	e.disabled = true
        } 
      }
      break    
    case 'lock': 
      Array.from(document.getElementsByTagName('button')).forEach(function (value, i, col) {
        value.disabled = true })
      break
    case 'unlock':
      Array.from(document.getElementsByTagName('button')).forEach(function (value, i, col) {
        value.disabled = false })
      break
	case 'poss':
		console.log(d[1].num[0])
    console.log(d[1].num[1])
	break
    default: 
	break
  }
}

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
      if ((new Date().getTime() - start) > milliseconds){
        break;
      }
    }
  }

function mode (btnID) {
   ws.send(btnID) 
}


function loadWindow (){
  Array.from(document.getElementsByTagName('button')).forEach(function (value, i, col) {
    col[i].onclick = function (e) { mode(e.target.id) }
  })
  createWs()
  console.log("start")
}
document.addEventListener('DOMContentLoaded', loadWindow, false)