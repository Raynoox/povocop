#include <stdbool.h>
#include <string.h>
#include <emscripten/emscripten.h>

int EMSCRIPTEN_KEEPALIVE sieveOfEratosthenes(int n) 
{ 
    bool prime[n+1]; 
    memset(prime, true, sizeof(prime)); 
  
    for (int p=2; p*p<=n; p++) 
    { 
        if (prime[p] == true) 
        { 
            for (int i=p*2; i<=n; i += p) 
                prime[i] = false; 
        } 
    } 
 
    int count = 0;
      for (int p=2; p<=n; p++) 
         if (prime[p]) {
        count++;
      }
    return count;
} 

