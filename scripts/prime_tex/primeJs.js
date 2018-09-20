function isPrime(input) {
    let prime = true;
    for (let i = 2; i*i <= input; i++) {
        if (input % i == 0) {
            prime = false;
            break;
        }
    }
    return prime && (input > 1);
}

function numberOfPrimes(iteration) {
let result = 0;
	for(var i =2; i< iteration; i++) {
		if(isPrime(i)){
			result++;
		}
	}
return result;
}

function sieveOfEratosthenes(n) {
    var prime = new Array(n+1).fill(true);
    for (var p=2; p*p<=n; p++) 
    { 
        if (prime[p] === true) 
        { 
            for (var i=p*2; i<=n; i += p) 
                prime[i] = false; 
        } 
    } 
    var count = 0;
    for (var p=2; p<=n; p++) 
        if (prime[p]) {
            count++;
    }
    return count;
}

function sleep(ms) { 
	return new Promise(resolve => setTimeout(resolve, ms));
};

var timer = function() {
 var start = new Date();
 return {
  stop: function(prefix) {
  var end = new Date();
  var time = end.getTime() - start.getTime();
document.getElementById("output").value = document.getElementById("output").value + "\n"+prefix+time
}}}

sleep(2000).then(() => {

var t = timer();
console.log("wasm"+_sieveOfEratosthenes(10000000));
t.stop("wasm");
var t = timer();
console.log("js"+sieveOfEratosthenes(10000000));
t.stop("js");
})
