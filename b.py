import time

import numpy as np
rng = np.random.default_rng()

N = 2000

# The performance boost is more dramatic for single precision.
m1 = rng.random((N, N), dtype='float32')
m2 = rng.random((N, N), dtype='float32')

start = time.time()
m1.dot(m2)
print("{:.2f}".format(time.time() - start))