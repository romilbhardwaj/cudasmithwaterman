A CUDA based implementation of the Smith Waterman Algorithm
By Romil Bhardwaj

The 32 bit binaries have been compiled with nvcc -arch=sm_10 for maximizing compatibility. The numeric suffix denotes the length of the sequences which will be generated and performed smith-waterman on. The code can be found in SmithWatermanGPU.cu.