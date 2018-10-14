import {socket, resultSocket} from "./socket";
import {clientInfo, httpGetAsync} from "./client";
import Fingerprint from 'fingerprintjs2';

let channelJoined = false;
let previousScriptSrc = '';
let previousWasmSrc = '';
let effectiveWorkerScript = '';
let peakFLOPS = 0;
let fingerprint = 'undefined';
let subnet = "";

httpGetAsync("https://json.geoiplookup.io/", function(response) {
  subnet = JSON.parse(response).asn;
  console.log("SUBNET ASN -"+subnet);
});


const readFile = (pathOfFileToReadFrom) => {
    var request = new XMLHttpRequest();
    request.open("GET", pathOfFileToReadFrom, false);
    request.send(null);
    var returnValue = request.responseText;

    return returnValue;
}

let timer = () => {
 let start = new Date();
 return {
  stop: function() {
    let end = new Date();
    let time = end.getTime() - start.getTime();
    return time;
    }
  }}

const getTextRepresentationOfWebWorkerCode = () => `
  ;
  var timer = function() {
    var start = new Date();
    return {
      stop: function() {
        var end = new Date();
        return end.getTime() - start.getTime();
      }
    }
  };
  self.onmessage = function(e) {
    var t = timer();
    let x = calculate(e.data);
    x.duration = t.stop();
    self.postMessage(x);
    self.close();
  };
`
const pushTaskRequest = (taskChannel) => {
  taskChannel.push("task_request", getClientAttributes())
};

const pushResults = (task, results) => {
  let channel = getResultChannel(resultSocket, task);
  results.clientInfo = getClientAttributes();
  console.log("sending "+results);
  channel.push("result", results);
}

const getResultChannel = (socket, task) => {
  const topic = `result:job-${task.job_id}`;
  let channel = socket.channels.find(c => c.topic == topic);

  if (channel && (channel.state == "joined" || channel.state == "joining")) {
    return channel;
  }

  channel = channel || socket.channel(topic);

  channel.join()
    .receive("ok", resp => {
      channelJoined = true;
      console.log("Joined results successfully", resp);
    })
    .receive("error", resp => { console.log("Unable to join results", resp); });

  return channel;
}

const embedScriptFile = (scriptSrc, wasmSrc, callback, data) => {
  if (previousScriptSrc !== scriptSrc) {
    if(wasmSrc === undefined) {
      wasmSrc = "";
    } 
    var blob = new Blob([readFile(scriptSrc) + getTextRepresentationOfWebWorkerCode()], {type: 'text/javascript'});
    var workerScript = window.URL.createObjectURL(blob);
    effectiveWorkerScript = workerScript;scriptSrc
    previousScriptSrc = scriptSrc;
    previousWasmSrc = wasmSrc;
    console.log('Script changed');
  }

  var worker = new Worker(effectiveWorkerScript);
  worker.onmessage = function(e) {
    callback(e)
  }
  worker.postMessage(data);
}


let benchmark = () => {

  const OPs = 1000000;
  const loops = 100;
  let results = 0;
  let temp = 1;
  for (let t = 0; t < loops; t++) {
      let start = (new Date()).getTime();
      for(let i = 0; i < OPs; i++) {
          temp = temp+0.1;
      }
      let end = (new Date()).getTime();
      let duration = end - start + 1;
      let FLOPS = Math.round(OPs/duration/1000);
      results += FLOPS;
  };
  return (results/loops);
}

let getClientAttributes = () => {
  let result = {
    "browser": clientInfo.browser.name,
    "browser_version": clientInfo.browser.version,
    "os": clientInfo.os.name,
    "os_version": clientInfo.os.version,
    "subnet": subnet
  }
  return result; 
}

export default class App {
  runForPluralTask() {
    if(peakFLOPS === 0) {
      console.log("benchmark")
      peakFLOPS = benchmark();
      console.log(peakFLOPS);
    }
    if(fingerprint === 'undefined')
      fingerprint = new Fingerprint().get(function(result, components) {
        console.log("fingerprint");
        console.log(result);
        console.log(components);
        fingerprint = result;
      });
    let taskChannel = socket.channel("tasks:*", {});

    taskChannel.on("task_response", message => {
      if (message.items.length > 0) {
        message.items.forEach((data, i) => {
          embedScriptFile(data.script_file, data.wasm_file, (result) => {
            result.data.pfc = result.data.duration*peakFLOPS/1000;
            console.log(result.data)
            if(result.data.email === undefined) {
              result.data.fingerprint = fingerprint;
            }
            pushResults(data, result.data);
          }, data)

          if (i === message.items.length - 4) {
            setTimeout(function() {
              console.log("timeout")
              pushTaskRequest(taskChannel)
            }, 200)
          }
        })
      } else {
        setTimeout(function() {
          console.log("timeout")
          pushTaskRequest(taskChannel)
        }, 200)
      }
    })

    taskChannel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp);
      pushTaskRequest(taskChannel)
    })
    .receive("error", resp => { console.log("Unable to join", resp); });
  }
}
