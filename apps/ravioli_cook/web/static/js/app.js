import {socket, resultSocket} from "./socket";
import Fingerprint from 'fingerprintjs2';

const pushTaskRequest = (taskChannel) => {
  taskChannel.push("task_request", {})
};

const pushResults = (task, results) => {
  let channel = getResultChannel(resultSocket, task);
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
      console.log("Joined results successfully", resp);
    })
    .receive("error", resp => { console.log("Unable to join results", resp); });

  return channel;
}

const embedScriptFile = (scriptSrc, callback) => {
  const id = "fetched-script-tag";
  let oldScriptTag = document.getElementById(id);

  if (oldScriptTag && oldScriptTag.src == scriptSrc) {
    callback();
  }
  else {
    if (oldScriptTag) oldScriptTag.remove();

    let scriptTag = document.createElement('script');
    scriptTag.src = scriptSrc;

    scriptTag.onload = callback;
    scriptTag.onreadystatechange = callback;

    scriptTag.id = id;

    document.head.appendChild(scriptTag);
  }
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

let benchmark = () => {

  const OPs = 1000000;
  const loops = 100;
  let results = 0;
  let temp = 1;
  for (let t = 0; t < loops; t++) {
      let start = (new Date()).getTime();
      for(let i = 0; i < OPs; i++) {
          temp = temp*Math.random()
      }
      let end = (new Date()).getTime();
      let duration = end - start;
      let FLOPS = OPs/duration;
      results += FLOPS;
  };
  return (results/loops)/1000;
}

export default class App {
  run() {
    let peakFLOPS = 0;
    let fingerprint;
    
    let taskChannel = socket.channel("tasks:*", {});
    taskChannel.on("task_response", data => {
      embedScriptFile(data.script_file, () => {
      let t = timer();
      let results = calculate(data)
      results.pfc = peakFLOPS*t.stop();
      if(!!results.email) {
        results.fingerprint = fingerprint;
      }
      pushResults(data, results)
      pushTaskRequest(taskChannel)
      });
    });
    taskChannel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp);
      peakFLOPS = benchmark();
      fingerprint = new Fingerprint().get(function(result, components) {
        console.log("fingerprint");
        console.log(result);
        console.log(components);
        fingerprint = result;
      });
      pushTaskRequest(taskChannel)
    })
    .receive("error", resp => { console.log("Unable to join", resp); });
  }
}
