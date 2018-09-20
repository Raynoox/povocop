#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <emscripten/emscripten.h>
/*int isPrime(int input) {
    int prime = 0;
	int i;
    for (i = 2; i*i <= input; i++) {
        if (input % i == 0) {
            prime = 1;
            break;
        }
    }
	if(input > 2 && prime == 1)
		return 1;
	return 0;
}*/
 
/*int numberOfPrimes(int iteration) {
		

	int result = 0;
	
	clock_t start = clock();
	int i;
	for(i =2; i< iteration; i++) {
		if(isPrime(i)==0){
			result++;		
		}
	}
	clock_t end = clock();
	float seconds = (float)(end - start) / CLOCKS_PER_SEC;
	printf("Time taken: %f\n", seconds);
	return result;
}*/
//EMSCRIPTEN_KEEPALIVE
int EMSCRIPTEN_KEEPALIVE sieveOfEratosthenes(int n) 
{ 

    clock_t start = clock();
    bool prime[n+1]; 
    memset(prime, true, sizeof(prime)); 
  
    for (int p=2; p*p<=n; p++) 
    { 
        // If prime[p] is not changed, then it is a prime 
        if (prime[p] == true) 
        { 
            // Update all multiples of p 
            for (int i=p*2; i<=n; i += p) 
                prime[i] = false; 
        } 
    } 
  
	clock_t end = clock();
	float seconds = (float)(end - start) / CLOCKS_PER_SEC;
	printf("Time taken: %f\n", seconds);
    int count = 0;
    // Print all prime numbers 
      for (int p=2; p<=n; p++) 
         if (prime[p]) {
        count++;
      }
    return count;
          //printf("%d ",p); 
} 

int main(int argc, char ** argv) {

   int iter = 5000;
   printf("%d\n",sieveOfEratosthenes(7500000));
   //printf("%d\n",numberOfPrimes(100000));
   //	clock_t start = clock();
//   calculatePi(denominator);	
   //clock_t end = clock();
   
   //float seconds = (float)(end - start) / CLOCKS_PER_SEC;
   //printf("Time taken: %f\n", seconds);
}
