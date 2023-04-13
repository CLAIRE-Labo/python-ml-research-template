"""
A quick benchmark for PyTorch
https://pytorch.org/tutorials/recipes/recipes/benchmark.html
"""

import torch
import timeit


def batched_dot_mul_sum(a, b):
    '''Computes batched dot by multiplying and summing'''
    return a.mul(b).sum(-1)


def batched_dot_bmm(a, b):
    '''Computes batched dot by reducing to bmm'''
    a = a.reshape(-1, 1, a.shape[-1])
    b = b.reshape(-1, b.shape[-1], 1)
    return torch.bmm(a, b).flatten(-3)


def benchmark_value(x):
    t0 = timeit.Timer(
        stmt='batched_dot_mul_sum(x, x)',
        setup='from __main__ import batched_dot_mul_sum',
        globals={'x': x})

    t1 = timeit.Timer(
        stmt='batched_dot_bmm(x, x)',
        setup='from __main__ import batched_dot_bmm',
        globals={'x': x})

    # Ran each twice to show difference before/after warmup
    print(f'mul_sum(x, x):  {t0.timeit(100) / 100 * 1e6:>5.1f} us')
    print(f'mul_sum(x, x):  {t0.timeit(100) / 100 * 1e6:>5.1f} us')
    print(f'bmm(x, x):      {t1.timeit(100) / 100 * 1e6:>5.1f} us')
    print(f'bmm(x, x):      {t1.timeit(100) / 100 * 1e6:>5.1f} us')


def benchmark(b_cpu=64, b_gpu=1024):
    # Input for benchmarking
    x = torch.randn(10000, b_cpu)
    assert batched_dot_mul_sum(x, x).allclose(batched_dot_bmm(x, x))

    print("CPU benchmark:")
    benchmark(x)

    print("GPU benchmark:")
    print('CUDA is available:', torch.cuda.is_available())
    x = torch.randn(10000, b_gpu, device='cuda' if torch.cuda.is_available() else 'cpu')
    benchmark(x)
