%%cu
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda.h>

#define N 4
#define TPB 2

__global__ void vecAdd(double *a, double *b, double *c, int n)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;

    if (id < n)
        c[id] = a[id] + b[id];
}

__global__ void matrixMultiplication(int *a, int *b, int *c, int n)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    int sum = 0;

    if (row < n && col < n)
    {
        for (int i = 0; i < n; i++)
        {
            sum += a[row * n + i] * b[i * n + col];
        }

        c[row * N + col] = sum;
    }
}

void vecAdd()
{
    int n = 100000;

    double *h_a;
    double *h_b;
    double *h_c;

    double *d_a;
    double *d_b;
    double *d_c;

    size_t bytes = n * sizeof(double);

    h_a = (double*)malloc(bytes);
    h_b = (double*)malloc(bytes);
    h_c = (double*)malloc(bytes);

    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    for (int i = 0; i < n; i++)
    {
        h_a[i] = i;
        h_b[i] = i;
    }

    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

    int blockSize = 1024;
    int gridSize = (int)ceil((float)n / blockSize);

    vecAdd<<<gridSize, blockSize>>>(d_a, d_b, d_c, n);

    cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);

    double sum = 0;

    for (int i = 0; i < n; i++)
        sum += h_c[i];

    printf("Sum: %f\n", sum / n);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    free(h_a);
    free(h_b);
    free(h_c);
}

void matMul()
{
    int *h_a, *h_b, *h_c;
    int *d_a, *d_b, *d_c;

    int size = sizeof(int) * N * N;

    cudaEvent_t start, end;
    float time = 0;

    h_a = (int*)malloc(size);
    h_b = (int*)malloc(size);
    h_c = (int*)malloc(size);

    cudaEventCreate(&start);
    cudaEventCreate(&end);

    cudaEventRecord(start);

    cudaMalloc(&d_a, size);
    cudaMalloc(&d_b, size);
    cudaMalloc(&d_c, size);

    for (int i = 0; i < N * N; i++)
    {
        h_a[i] = random() % N;
        h_b[i] = random() % N;
    }

    printf("\nMatrix A =>\n\n");

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            printf("%d ", h_a[i * N + j]);
        }
        printf("\n");
    }

    printf("\nMatrix B =>\n\n");

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            printf("%d ", h_b[i * N + j]);
        }
        printf("\n");
    }

    cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

    int BLOCK_SIZE = N / TPB;

    dim3 GridSize(BLOCK_SIZE, BLOCK_SIZE);
    dim3 BlockSize(TPB, TPB);

    matrixMultiplication<<<GridSize, BlockSize>>>(d_a, d_b, d_c, N);

    cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);

    cudaEventRecord(end);
    cudaEventSynchronize(end);

    cudaEventElapsedTime(&time, start, end);

    printf("\nMatrix C =>\n\n");

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            printf("%d ", h_c[i * N + j]);
        }
        printf("\n");
    }

    printf("Time taken to perform %d by %d matrix mul is: %lf ms", N, N, time);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    free(h_a);
    free(h_b);
    free(h_c);
}

int main()
{
    printf("Add two large vectors \n");

    vecAdd();

    printf("\n\n\n Multiply two N × N arrays using n2 processors\n");

    matMul();

    return 0;
}