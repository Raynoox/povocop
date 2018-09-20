#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <time.h>

double  calculatePi(int denominator) {
      double x,y;
      double pi;
   int count=0;
   int i;

clock_t start = clock();
      for ( i=0; i<denominator; i++) {
      x = (double)rand()/RAND_MAX;
      y = (double)rand()/RAND_MAX;
      if ((x*x+y*y)<=1) 
         count++;
      if(i%10000000==0){
         clock_t tempEnd = clock();
         
         float seconds = (float)(tempEnd - start) / CLOCKS_PER_SEC;
         printf("Iteration: %d. Time taken: %f\n", i, seconds);
      }
   }
  
   pi=(double)count/denominator*4;
   clock_t end = clock();
   float seconds = (float)(end - start) / CLOCKS_PER_SEC;
   printf("Time taken: %f\n", seconds);
   return pi;
}
int main(int argc, char ** argv) {

   srand(time(NULL));   // should only be called once
   printf("Hello WorldX\n");
   int denominator;
   int result = 0;
    do
   {
   result = scanf("%d", &denominator);
   printf(" sprawdzam - %d, %d", result, denominator);
   //	clock_t start = clock();
   printf("%f\n",calculatePi(denominator));	
   //clock_t end = clock();
   }while(denominator != 0);
   
   //float seconds = (float)(end - start) / CLOCKS_PER_SEC;
   //printf("Time taken: %f\n", seconds);
}
