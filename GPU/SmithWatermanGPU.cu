//A CUDA based implementation of the Smith Waterman Algorithm
//Author: Romil Bhardwaj

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<time.h>

#include <stdio.h>
#include <stdlib.h>
#define max(a,b) (((a)>(b))?(a):(b))

//Define the costs here
#define indel -1
#define match 2
#define mismatch -1

//CHANGE THIS VALUE TO CHANGE THE NUMBER OF ELEMENTS
const int arraySize = 500;
//CHANGE THIS VALUE TO CHANGE THE NUMBER OF ELEMENTS

cudaError_t SWHelper(int (*c)[arraySize+1], const char *a, const char *b, size_t size);


__global__ void SmithWKernelExpand(int (*c)[arraySize+1], const char *a, const char *b, const int *k)		//Declared consts to increase access speed
{
    int i = threadIdx.x+1;
	int j = ((*k)-i)+1;
	int north=c[i][(j)-1]+indel;			//Indel
	int west=c[i-1][j]+indel;
	int northwest;
	if (((int) a[i-1])==((int)b[(j)-1]))
		northwest=c[i-1][(j)-1]+match;		//Match
	else
		northwest=c[i-1][(j)-1]+mismatch;		//Mismatch
    c[i][j] = max(max(north, west),max(northwest,0));
	//c[i][j]=(*k);						//Debugging - Print the antidiag num
}

__global__ void SmithWKernelShrink(int (*c)[arraySize+1], const char *a, const char *b, const int *k)
{
    int i = threadIdx.x+((*k)-arraySize)+1;
	int j = ((*k)-i)+1;
	int north=c[i][(j)-1]+indel;			//Indel
	int west=c[i-1][j]+indel;
	int northwest;
	if (((int) a[i-1])==((int)b[(j)-1]))
		northwest=c[i-1][(j)-1]+match;		//Match
	else
		northwest=c[i-1][(j)-1]+mismatch;		//Mismatch
    c[i][j] = max(max(north, west),max(northwest,0));
	//c[i][j]=(*k);						//Debugging - Print the antidiag num
}

void print(int c[arraySize+1][arraySize+1]){
	int j=0,i=0;
	for (i = 0; i < arraySize+1; i++) {
        for (j = 0; j < arraySize+1; j++) {
            printf("%d \t", c[i][j]);
        }
        printf("\n");
	}
}

void traceback(int c[arraySize+1][arraySize+1], char a[], char b[]){
	int j=0,i=0;
	int maxi=0,maxj=0,max=0;
	for (i = 0; i < arraySize+1; i++) {
        for (j = 0; j < arraySize+1; j++) {
           if(c[i][j]>max){
			   maxi=i;
			   maxj=j;
				max=c[i][j];
		   }
        }
	}
	i=maxi;
	j=maxj;
	printf("The optimal local alignment starts at index %d for a, and index %d for b.\n", i,j);
	while (c[i][j]!=0 && i>=0 && j>=0 ){
		printf("\n");
		if (c[i][j]==c[i-1][(j)-1]+match){		//From match
			i--;
			j--;
			printf("%c -- %c", a[i], b[j]);
		}
		else if (c[i][j]==c[i-1][(j)-1]+mismatch){ //From mismatch
			i--;
			j--;
			printf("%c -- %c", a[i], b[j]);
		}
		else if (c[i][j]==c[i][(j)-1]+indel){	//North
			j--;
			printf("- -- %c", b[j]);
		}
		else{									//Else has to be from West
			i--;
			printf("%c -- -", a[i]);
		}
	}
	
	printf("\n\nThe optimal local alignment ends at index %d for a, and index %d for b.\n", i,j);
}


int main()
{
	char b[arraySize];//{'a','c','a','c','a','c','t','a'};
	char a[arraySize];//{'a','g','c','a','c','a','c','a'};
	
	int i=0;
	
	//Generating the sequences:
	
	srand (time(NULL));
	printf("\nString a is: ");
    for(i=0;i<arraySize;i++)
    {
        int gen1=rand()%4;
        switch(gen1)
        {
            case 0:a[i]='a';
            break;
            case 1: a[i]='c';
            break;
            case 2: a[i]='g';
            break;
            case 3: a[i]='t';
        }
		//a[i]='a';
		printf("%c ", a[i]);
    }

	printf("\nString b is: ");
	for(i=0;i<arraySize;i++)
    {
        int gen1=rand()%4;
        switch(gen1)
        {
            case 0:b[i]='a';
            break;
            case 1: b[i]='c';
            break;
            case 2: b[i]='g';
            break;
            case 3: b[i]='t';
        }
		//b[i]='a';
		printf("%c ", b[i]);
    }
	
	
	printf("\nOkay, generated the string \n");
	int c[arraySize+1][arraySize+1] = { {0} };

	clock_t start=clock();

    // Run the SW Helper function
    cudaError_t cudaStatus = SWHelper(c, a, b, arraySize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "SWHelper failed!");
        return 1;
    }
	
	clock_t end=clock();

	//Printing the final score matrix. Uncomment this to see the matrix.
	//print(c);

	
	

    // cudaDeviceReset must be called before exiting in order for profiling and
    // tracing tools such as Nsight and Visual Profiler to show complete traces.
    cudaStatus = cudaDeviceReset();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceReset failed!");
        return 1;
    }

	traceback (c,a,b);
	printf("\n\nEnter any number to exit.");
	printf("\n\nTotal time taken is %f seconds\n",(double)(end-start)/CLOCKS_PER_SEC);
	int x;
	scanf("%d", &x);
    return 0;
}

// Helper function for SmithWaterman
cudaError_t SWHelper(int (*c)[arraySize+1], const char *a, const char *b, size_t size)
{
    char *dev_a;
    char *dev_b;
	int (*dev_c)[arraySize+1] = {0};
	int (*j)=0;
	int *dev_j;
    cudaError_t cudaStatus;

    // Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaStatus = cudaMalloc((void**)&dev_c, (size+1) * (size+1) * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(char));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(char));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

	cudaStatus = cudaMalloc((void**)&dev_j, sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Copy input vectors from host memory to GPU buffers.
    cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(char), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

	cudaStatus = cudaMemcpy(dev_j, &j, sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }


    cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(char), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

	cudaStatus = cudaMemcpy(dev_c, c, (size+1) * (size+1) * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

	int i=0;
	clock_t start1=clock();

    // Launch a kernel on the GPU with one thread for each element.

	//Expanding Phase
	for (i=1; i<size+1; i++){
		cudaStatus = cudaMemcpy(dev_j, &i, sizeof(int), cudaMemcpyHostToDevice);
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "cudaMemcpy failed!", cudaStatus);
			goto Error;
		}
		SmithWKernelExpand<<<1, i>>>(dev_c, dev_a, dev_b, dev_j);
	}

	//Shrink Phase
	for (int k=size-1; k>0; k--, i++){
		cudaStatus = cudaMemcpy(dev_j, &i, sizeof(int), cudaMemcpyHostToDevice);
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "cudaMemcpy failed!");
			goto Error;
		}

		SmithWKernelShrink<<<1, k>>>(dev_c, dev_a, dev_b, dev_j);
	}
	clock_t end1=clock();
    printf("\n\nKernel Time taken is %f seconds\n",(double)(end1-start1)/CLOCKS_PER_SEC);


    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching SmithWKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy output vector from GPU buffer to host memory.
	//cudaStatus = cudaMemcpy2D(c,size * size * sizeof(int),dev_c,size * size * sizeof(int),size * size * sizeof(int),size * size * sizeof(int),cudaMemcpyDeviceToHost);
    cudaStatus = cudaMemcpy(c, dev_c, (size+1) * (size+1) * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_c);
    cudaFree(dev_a);
    cudaFree(dev_b);
    
    return cudaStatus;
} 
