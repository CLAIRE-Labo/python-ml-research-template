"""
Quick benchmark for NumPy
https://gist.github.com/bebosudo/6f43dc6b4329c197f258f25cc69f0ec0
"""

import time
import numpy as np


def benchmark(n=2000):
    rng = np.random.default_rng()

    # The performance boost is more dramatic for single precision.
    m1 = rng.random((n, n), dtype='float32')
    m2 = rng.random((n, n), dtype='float32')

    start = time.time()
    m1.dot(m2)
    print("{:.2f}".format(time.time() - start))
