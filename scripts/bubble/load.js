      function reqListener () {
        // Loading wasm module
        var arrayBuffer = oReq.response;
        Module['wasmBinary'] = arrayBuffer;
        //wasmDsp = Module({ wasmBinary: Module.wasmBinary });
        sort = Module.cwrap('bubbleSort', null, ['number', 'number']);

        justSort = Module.cwrap('justBubbleSort', null, ['number', 'number']);
     };

    function sleep(ms) { 
       return new Promise(resolve => setTimeout(resolve, ms));
    };
   function execute() {;
      oReq.open("GET", "bubbleSort.wasm");
      oReq.send();
}
      var oReq = new XMLHttpRequest();
      oReq.responseType = "arraybuffer";
      oReq.addEventListener("load", reqListener)
  execute();

        // Takes an Int32Array, copies it to the heap and returns a pointer
        function arrayToPtr(array) {
          var ptr = Module._malloc(array.length * nByte)
          Module.HEAP32.set(array, ptr / nByte)
          return ptr
        }

        // Takes a pointer and  array length, and returns a Int32Array from the heap
        function ptrToArray(ptr, length) {
          var array = new Int32Array(length)
          var pos = ptr / nByte
          array.set(Module.HEAP32.subarray(pos, pos + length))
          return array
        }

function bubble(arr) {
     var result = arr;
      var len = result.length;
    
      for (var i = 0; i < len ; i++) {
        for(var j = 0 ; j < len - i - 1; j++){ 
        if (result[j] > result[j + 1]) {
          // swap
          var temp = result[j];
          result[j] = result[j+1];
          result[j + 1] = temp;
        }
       }
      }
      return result;
    }
	
	var tempA = Array.from({length: 10000}, () => Math.floor(Math.random() * 10000))
        var inArray = new Int32Array(tempA);
        var nByte = 4

var timer = function() {
 var start = new Date();
 return {
  stop: function() {
  var end = new Date();
  var time = end.getTime() - start.getTime();
document.getElementById("output").value = document.getElementById("output").value + "\n"+time
}}}




    console.log("sleep");
    sleep(2000).then(() => {console.log("wake");

var t = timer();
console.log("startTimer")
       var copiedArray = ptrToArray(
        sort(arrayToPtr(inArray), inArray.length)
       , inArray.length);
       // var p = sort(arrayToPtr(inArray), inArray.length);
       //sort(arrayToPtr(inArray));
t.stop();
console.log(copiedArray);
var t = timer();
justSort(arrayToPtr(inArray), inArray.length);
t.stop()
//var tempB = Array.from({length: 10000}, () => Math.floor(Math.random() * 10000));
var t = timer();
bubble(inArray);
t.stop();
	});

