i = 32
h = 6
rate = 1e-1
batch_size = 90
dtype = float16

Initial weights = 1/32 (all same)

Output format:
32 weights connect all input neurons to a single ith hidden neuron. This weight is called hi. So there are h0, h1 ... h5 weights. The evolution of these weights after each batch is stored in files hi.csv.