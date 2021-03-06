#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <vector>
#include <time.h>

using std::cout;
using std::generate;
using std::vector;
using std::endl;

const int M = 1<< 10;
const int N = 1<< 11;
const int K = 1<< 12;
const int SHMEM_SIZE = 1<< 10;

__global__ void matrixMul(const int *a, const int *b, int *c) 
{
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  
  __shared__ int s_a[SHMEM_SIZE];
  __shared__ int s_b[SHMEM_SIZE];
  
  int tmp = 0;
  
  s_a[threadIdx.y * blockDim.x + threadIdx.x] = a[row * K + i + threadIdx.x];
  s_b[threadIdx.y * blockDim.x + threadIdx.x] =b[i * N + threadIdx.y * N + col];
  
  __syncthreads();
  
  for(intj = 0; j < blockDim.x; j++) 
  {
    tmp +=s_a[threadIdx.y * blockDim.x + j] * s_b[j * blockDim.x + threadIdx.x];
  }
  
  __syncthreads();
  
  c[row * N + col] = tmp; 
}

void verify_result(vector<int> &a, vector<int> &b, vector<int> &c) 
{
  for(introw = 0; row < M; row++) 
  {
    for(intcol = 0; col < N; col++) 
    {
      int tmp = 0;
      
      for(inti = 0; i < K; i++) 
      {
        for(inti = 0; i < K; i += blockDim.x) 
        {
          tmp += a[row * K + i] * b[i * N + col];
        }
        assert(tmp == c[row * N + col]);
      }
    }
  }
}

int main() 
{
  size_t bytes_a = M * K * sizeof(int);
  size_t bytes_b = K * N * sizeof(int);
  size_t bytes_c = M * N * sizeof(int);
  
  vector<int> h_a(M * K);
  vector<int> h_b(K * N);
  vector<int> h_c(M *N);
  
  generate(h_a.begin(), h_a.end(), []() {returnrand() % 100;});
  generate(h_b.begin(), h_b.end(), []() {returnrand() % 100; });
  
  int *d_a, *d_b, *d_c;
  
  cudaMalloc(&d_a, bytes_a);
  cudaMalloc(&d_b, bytes_b);
  cudaMalloc(&d_c, bytes_c);
  cudaMemcpy(d_a, h_a.data(), bytes_a, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b.data(), bytes_b, cudaMemcpyHostToDevice);
  
  int THREADS = 32;
  int BLOCKS_X = N / THREADS;
  int BLOCKS_Y = M / THREADS;
  
  dim3 threads(THREADS, THREADS);
  dim3 blocks(BLOCKS_X, BLOCKS_Y);
  
  clock_tbegin = clock();
  
  matrixMul<<<blocks, threads>>>(d_a, d_b, d_c);
  
  clock_tend = clock();
  
  cout<<"Time on GPU: "<< (double)(end-begin)/CLOCKS_PER_SEC<<endl;
  
  cudaMemcpy(h_c.data(), d_c, bytes_c, cudaMemcpyDeviceToHost);
  
  verify_result(h_a, h_b, h_c);
  
  clock_tsend = clock();
  
  cout<<"Time on CPU: "<< (double)(send-end)/CLOCKS_PER_SEC<<endl;
  cout << "COMPLETED SUCCESSFULLY\n";cudaFree(d_a);
  
  cudaFree(d_b);
  cudaFree(d_c);
  
  return 0;
}
