#include <stdio.h>
#include <stdlib.h>
#include <time.h>
//#include <emscripten/emscripten.h>

void swapNum(int *a, int *b, int *temp) {
    *temp = *a;
    *a = *b;
    *b = *temp;
}

int* bubbleSort(int *array, int length) {

clock_t start = clock();
    int temp;
    int i,j;
    for(i=0; i<length;i++){
        for(j=0; j<length-1-i; j++){
            if(array[j] > array[j+1]){
                //swapNum(&(array[j+1]), &(array[j]), &temp);
                temp = array[j];
                array[j] = array[j+1];
                array[j+1] = temp;
            }
        }
    }
   clock_t end = clock();
   float seconds = (float)(end - start) / CLOCKS_PER_SEC;
   printf("Time taken: %f\n", seconds);
    return array;
}

void justBubbleSort(int *array, int length) {

    int temp;
    int i,j;
    for(i=0; i<length;i++){
        for(j=0; j<length-1-i; j++){
            if(array[j] > array[j+1]){
                //swapNum(&(array[j+1]), &(array[j]), &temp);
                temp = array[j];
                array[j] = array[j+1];
                array[j+1] = temp;
            }
        }
    }
}

int main(int argc, char ** argv) {
    srand(time(NULL));
    int len=10000;
    int numbers[len];
    
    numbers[0] =0;
    numbers[1] =2;
    numbers[2] =1;
    numbers[3] =1;
    numbers[4] =3;
    numbers[5] =4;
    numbers[6] =5;
    numbers[7] =9;
    numbers[8] =8;
    numbers[9] =0;
    //bubbleSort(numbers, 10);
    int i;
    for(i = 0; i < len; i++)
    numbers[i] = rand()%10000;
    bubbleSort(numbers, len);
    //for(i = 0; i < len; i++)
    //printf("numbers[%d] = %d\n", i, numbers[i]);
}


