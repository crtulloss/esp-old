# Usage of MatchLib Arbitrated Scratchpads

The designs `ArbitratedScratchpadWrapper` and `ArbitratedScratchpadDPWrapper` use the [MatchLib memory components](https://nvlabs.github.io/matchlib/group___arbitrated_scratchpad.html) `ArbitratedScratchpad` and `ArbitratedScratchpadDP` respectively.

The designs are paradigmactic of the load-compute-store structure of an ESP accelerator but simpler.

In both the cases (`ArbitratedScratchpadWrapper` and `ArbitratedScratchpadDPWrapper`), the design top module has two processes that behave like in the following pseudo-code and image:

```
process_1:
for (i = 0; i < BURST_COUNT; i++)
    for (j = 0; j < BURST_SIZE; j++)
        data = read_data_from_testbench();
        index = (i * BURST_SIZE + j) % MEM_SIZE
        arbitrated_scratchpad_wrapper.port1.write(index, data)
    sync_with_the_other_process()

process_2:
for (i = 0; i < BURST_COUNT; i++)
    sync_with_the_other_process()
    for (j = 0; i < BURST_SIZE; i++)
        index = (i * BURST_SIZE + j) % MEM_SIZE
        data = arbitrated_scratchpad_wrapper.port2.read(index)
        write_data_to_testbench(data)
```

To replicate the experiments:

``
./get_boost_1_68_0.sh
```

```
cd <ArbitratedScratchpad*Wrapper>
make
make run
make syn
```

## References

- [Slides](https://docs.google.com/presentation/d/1pwKd-JKmadxN98U0Qt4mZs1unXBNXEb6HYyhML4dOEI/edit?usp=sharing)
