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
let allCells
// let innercell = `<table id="gridi">
// <tr>
// <td id="cell-i0">1</td>
// <td id="cell-i1">2</td>
// <td id="cell-i2">3</td>
// </tr>
// <tr>
// <td id="cell-i3">4</td>
// <td id="cell-i4">5</td>
// <td id="cell-i5">6</td>
// </tr>
// <tr>
// <td id="cell-i6">7</td>
// <td id="cell-i7">8</td>
// <td id="cell-i8">9</td>
// </tr>
// </table>`
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
       // console.log("cell-" + i.toString())
        if(n[i] === '0'){
          //e.innerHTML = getinner(i)
          console.log (getinner(i))
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
    allCells = d[1].num 
   // console.log (allCells)

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
 // console.log("start")
}
document.addEventListener('DOMContentLoaded', loadWindow, false)


function getinner (q){ 
      console.log(q)
      i=allCells[q]
       for (var  j= 1; j < 10; j++) {
          //console.log(i , j, (allCells[i][j-1] !== undefined) ? allCells[i][j-1]: null)
         // if(allCells[i][j-1] !== undefined){
          //  console.log(i , j, (allCells[i].includes(j)? j : null))
          let triples=(j===3 || j===6 || j === 9)
          
        //  console.log( ((j===1)?"<table id=\"cell-" + i + "\">" :"") +
        //                             "<td id=\"cellInner-" + (j).toString() + "\">" + (allCells[i].includes(j)? j.toString() : "") + "</td>" + 
        //                             (triples?"</tr><tr>":"") +
        //                             ((j===9)?"</table>" :""))
        return (allCells[0][1])
       }
    }


  //   let cellValueStrings = new Array()
  // for (var i = 0; i < num1.length; i++) {
    //    let cellValueStrings = new Array()
    //   for (var  j= 1; j < 9; j++) {
    //     if(num1[i].includes(j)){
    //       //cellValueStrings.push("<td id=\"cellInner-" + j.toString() + "\">" + num1[i][j].toString() + "</td>" )  
    //       console.log(num1[i][j])
    //     }else{
    //       cellValueStrings.push("<td id=\"cellInner-" + j.toString() + "\"></td>" )    
        
    //     }
    //   console.log(cellValueStrings[j])  
    //   }
//  const e = document.getElementById("cell-" + i.toString())
//               e.innerHTML.innerHTML.
 

 
    // for (var i = 0; i < allCells .length; i++) {
    //   //console.log(i)
    
    //    for (var  j= 1; j < 10; j++) {
    //       //console.log(i , j, (allCells[i][j-1] !== undefined) ? allCells[i][j-1]: null)
    //      // if(allCells[i][j-1] !== undefined){
    //      //   console.log(i , j, (allCells[i].includes(j)? j : null))
    //        // console.log("<td id=\"cellInner-" + (j-1).toString() + "\">" + (allCells[i].includes(j)? j.toString() : "") + "</td>")
    //      // }else{
    //        // console.log(i , j, null)
    //      // }
    //    }
    // }

    
    // for (var i = 0; i < allCells.length; i++) {     
    //    for (var  j= 1; j < 10; j++) {
    //       //console.log(i , j, (allCells[i][j-1] !== undefined) ? allCells[i][j-1]: null)
    //      // if(allCells[i][j-1] !== undefined){
    //       //  console.log(i , j, (allCells[i].includes(j)? j : null))
    //       let triples=(j===3 || j===6 || j === 9)
          
    //       let inner = ((j===1)?"<table id=\"cell-" + i + "\">" :"") +
    //                                 "<td id=\"cellInner-" + (j).toString() + "\">" + (allCells[i].includes(j)? j.toString() : "") + "</td>" + 
    //                                 (triples?"</tr><tr>":"") +
    //                                 ((j===9)?"</table>" :"")
    //         console.log(inner)
    //      // }else{
    //        // console.log(i , j, null)
    //      // }
    //    }
    // }