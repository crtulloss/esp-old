// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// modified by CRT, Columbia University, Bioelectronic Systems Lab

#include "mindfuzz.hpp"
#include "mindfuzz_directives.hpp"

// Functions

#include "mindfuzz_functions.hpp"

// Processes

void mindfuzz::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();

        // explicit PLM ports reset if any
        // this would be necessary if we accessed PLMs explicitely
        // by default, they are mapped to arrays so we read and writ
        // with indices just like arrays

        // User-defined reset code

        wait();
    }

    // Config
    int32_t do_relu;
    int32_t window_size;
    int32_t batches_perload;
    TYPE learning_rate;
    int32_t neurons_perwin;
    int32_t tsamps_perbatch;
    TYPE detect_threshold;
    int32_t num_windows;
    int32_t iters_perbatch;
    int32_t num_loads;

    // declare some necessary variables
    // int32_t load_batches;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        do_relu = config.do_relu;
        window_size = config.window_size;
        batches_perload = config.batches_perload;
        learning_rate = config.learning_rate;
        neurons_perwin = config.neurons_perwin;
        tsamps_perbatch = config.tsamps_perbatch;
        detect_threshold = config.detect_threshold;
        num_windows = config.num_windows;
        iters_perbatch = config.iters_perbatch;
        num_loads = config.num_loads;
    }

    // Load
    {
        HLS_PROTO("load-dma");
        wait();

        bool ping = true;
        uint32_t offset = 0;

        // Batching
        for (uint16_t b = 0; b < num_loads; b++)
        {
            wait();

// for 16b data, DMA_WORD_PER_BEAT = 2
// DMA_WORD_PER_BEAT would equal 0 if WORD size > BEAT size
#if (DMA_WORD_PER_BEAT == 0)
            uint32_t length = num_windows*window_size*tsamps_perbatch*batches_perload;
#else
            // broke up this computation and added some waits in order to improve schedule
            uint32_t length_dum = num_windows*window_size*tsamps_perbatch*batches_perload;
            wait();
            uint32_t length = round_up(length_dum, DMA_WORD_PER_BEAT);
#endif
            wait();
            // Chunking - in this case, no chunk, so one iteration per batch
            for (int rem = length; rem > 0; rem -= PLM_IN_WORD)
            {
                wait();
                // Configure DMA transaction
                uint32_t len = rem > PLM_IN_WORD ? PLM_IN_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
                offset += len;

                this->dma_read_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                for (uint16_t i = 0; i < len; i++)
                {
                    sc_dt::sc_bv<DATA_WIDTH> dataBv;

                    for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++)
                    {
                        dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH) = this->dma_read_chnl.get();
                        wait();
                    }

                    // Write to PLM
                    if (ping)
                        plm_in_ping[i] = dataBv.to_int64();
                    else
                        plm_in_pong[i] = dataBv.to_int64();
                }
#else
                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    // TODO what is this?
                    HLS_BREAK_DEP(plm_in_ping);
                    HLS_BREAK_DEP(plm_in_pong);

                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    dataBv = this->dma_read_chnl.get();
                    wait();

                    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        HLS_UNROLL_SIMPLE;
                        if (ping)
                            plm_in_ping[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                        else
                            plm_in_pong[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                    }
                }
#endif
                this->load_compute_handshake();
                ping = !ping;
                // chunk complete
            }
            // batch complete
        }
    }

    // Conclude
    {
        this->process_done();
    }
}

/*
// TODO this needs to be rewritten since I wrote it before i had
// the loop structure for compute, and before I figured out plm
// access
void mindfuzz::detect_kernel()
{
    // Reset
    {
        HLS_PROTO("detect-reset");

        this->reset_detect_kernel();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    int32_t do_relu;
    int32_t window_size;
    int32_t batches_perload;
    TYPE learning_rate;
    int32_t neurons_perwin;
    int32_t tsamps_perbatch;
    TYPE detect_threshold;
    int32_t num_windows;
    int32_t iters_perbatch;
    int32_t num_loads;
    {
        HLS_PROTO("detect-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        do_relu = config.do_relu;
        window_size = config.window_size;
        batches_perload = config.batches_perload;
        learning_rate = config.learning_rate;
        neurons_perwin = config.neurons_perwin;
        tsamps_perbatch = config.tsamps_perbatch;
        detect_threshold = config.detect_threshold;
        num_windows = config.num_windows;
        iters_perbatch = config.iters_perbatch;
        num_loads = config.num_loads;
    }


    // for coordination about input pingpong PLM
    bool ping = true;

    // for coordination about batching circular buffer
    uint8_t writeloc = 0;
    this->full = "0000";
    
    // length of time-series data per window and per electrode per input batch
    uint32_t len_perelec = tsamps_perbatch*batches_perload;
    uint32_t len_perwindow = window_size*len_perelec;
    uint32_t in_length = num_windows*len_perwindow;
    {
        for (uint16_t b = 0; b < num_loads; b++)
        {

            // since we have a chunking factor of 1, this only does one iteration
            for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD)
            {

                uint32_t in_len  = in_rem  > PLM_IN_WORD  ? PLM_IN_WORD  : in_rem;

                this->detect_load_handshake();

                // Computing phase implementation

                // parallel computation for each window
                for (int w = 0; w < num_windows; w++) {
                    // UNROLL THIS LOOP

                    uint32_t window_offset = len_perwindow*w;

                    // flag for whether there is a spike in this window
                    bool flag = false;
                    int16_t data = 0;
                    for (int elec = 0; elec < window_size; elec++) {
                        // UNROLL?

                        uint32_t elec_offset = len_perelec*elec;

                        for (int samp = 0; samp < len_perelec; samp++) {
                            if (ping)
                                data = plm_in_ping[window_offset + elec_offset + samp];
                            else
                                data = plm_in_pong[window_offset + elec_offset + samp];
                            if (data > detect_threshold) {
                                flag = true;
                                // if the window is flagged, we don't need to look at rest of data
                                samp = len_perelec;
                                elec = window_size;
                            }
                        }
                    }
                    if (flag) {
                        // IMPLEMENT storing data in buffer
                        // need to use fill and writeloc appropriately
                    }
                }

                this->detect_compute_handshake();
                ping = !ping;
            }
        }

        // Conclude
        {
            this->process_done();
        }
    }
}
*/

void mindfuzz::compute_kernel()
{
    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    int32_t do_relu;
    int32_t window_size;
    int32_t batches_perload;
    TYPE learning_rate;
    int32_t neurons_perwin;
    int32_t tsamps_perbatch;
    TYPE detect_threshold;
    int32_t num_windows;
    int32_t iters_perbatch;
    int32_t num_loads;

    // declare some necessary variables
    // int32_t load_batches;
    int32_t total_tsamps;
    int32_t input_dimension;
    int32_t output_dimension;
    int32_t layer1_dimension;
    int32_t W2_size;
    int32_t W1_size;
    int32_t B2_size;
    int32_t B1_size;
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        do_relu = config.do_relu;
        window_size = config.window_size;
        batches_perload = config.batches_perload;
        learning_rate = config.learning_rate;
        neurons_perwin = config.neurons_perwin;
        tsamps_perbatch = config.tsamps_perbatch;
        detect_threshold = config.detect_threshold;
        num_windows = config.num_windows;
        iters_perbatch = config.iters_perbatch;
        num_loads = config.num_loads;
        
        // total size of a load batch is useful for relevancy check
        total_tsamps = tsamps_perbatch * batches_perload;

        // some dimension computation useful for backprop
        input_dimension = window_size;
        output_dimension = input_dimension;
        layer1_dimension = neurons_perwin;

        W2_size = num_windows*output_dimension*layer1_dimension;
        W1_size = num_windows*layer1_dimension*input_dimension;
        B2_size = num_windows*output_dimension;
        B1_size = num_windows*layer1_dimension;
    }


    // Compute

    // initialize weights and biases
    {
        // initial value for each weight/bias
        TYPE initial_weight = 1.0;
        TYPE initial_bias = 0.0;

        // PLM access offsets for weights and biases
        uint32_t plm_offset_W1 = 0;
        uint32_t plm_offset_W2 = plm_offset_W1 + W1_size;
        uint32_t plm_offset_B1 = plm_offset_W2 + W2_size;
        uint32_t plm_offset_B2 = plm_offset_B1 + B1_size;

        // initialize W1
        for (uint32_t weight = 0; weight < W1_size; weight++) {
            plm_out[plm_offset_W1 + weight] =
                fp2int<TYPE, WORD_SIZE>(initial_weight);
        }
        // initialize W2
        for (uint32_t weight = 0; weight < W2_size; weight++) {
            plm_out[plm_offset_W2 + weight] =
                fp2int<TYPE, WORD_SIZE>(initial_weight);
        }
        // initialize B1
        for (uint32_t weight = 0; weight < B1_size; weight++) {
            plm_out[plm_offset_B1 + weight] =
                fp2int<TYPE, WORD_SIZE>(initial_bias);
        }
        // initialize B2
        for (uint32_t weight = 0; weight < B2_size; weight++) {
            plm_out[plm_offset_B2 + weight] =
                fp2int<TYPE, WORD_SIZE>(initial_bias);
        }
    }
    
    bool ping = true;

    // for relevancy detection
/*
    bool flag[num_windows];
*/
    // TODO fix to not use arbitrarily sized array
    bool flag[CONST_NUM_WINDOWS];

    // actual computation
    {
        for (uint16_t b = 0; b < num_loads; b++)
        {

            // no-chunk code
            // see below for old code with chunking
            this->compute_load_handshake();

            // run relevancy check
            // this will update the flag array to reflect
            // the training relevance of each window
            relevant(total_tsamps,
                     num_windows,
                     window_size,
                     flag,
                     ping,
                     detect_threshold);

            // run backprop for each compute batch in this load batch
            for (uint16_t batch = 0; batch < batches_perload; batch++) {

                // pass relevant parameters like sizes, flag, and pingpong
                // backprop will access weights, training data, biases directly (they are in PLMs)
                backprop(do_relu,
                         learning_rate,
                         learning_rate,
                         tsamps_perbatch,
                         num_windows,
                         iters_perbatch,
                         input_dimension,
                         layer1_dimension,
                         output_dimension,
                         W1_size,
                         W2_size,
                         B1_size,
                         B2_size,
                         batch,
                         flag,
                         ping);

                // this compute batch done
            }

            ping = !ping;
            // this piece of indata (load_batch) done

/*
            uint32_t in_length = num_windows*window_size*tsamps_perbatch*batches_perload;

            // since we have a chunking factor of 1, this only does one iteration
            // TODO add parameter to pass to backprop() so that we can
            // process a chunk by sections of the electrode array
            for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD)
            {

                uint32_t in_len  = in_rem  > PLM_IN_WORD  ? PLM_IN_WORD  : in_rem;

                
            }
*/

        }
        // all batches done (all backprop iterations complete)
        // we only store once, once all backprop iterations are complete
        this->compute_store_handshake();
    }
    // Conclude
    {
        this->process_done();
    }
}


void mindfuzz::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    int32_t do_relu;
    int32_t window_size;
    int32_t batches_perload;
    TYPE learning_rate;
    int32_t neurons_perwin;
    int32_t tsamps_perbatch;
    TYPE detect_threshold;
    int32_t num_windows;
    int32_t iters_perbatch;
    int32_t num_loads;

    // declare some necessary variables
    // int32_t load_batches;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        do_relu = config.do_relu;
        window_size = config.window_size;
        batches_perload = config.batches_perload;
        learning_rate = config.learning_rate;
        neurons_perwin = config.neurons_perwin;
        tsamps_perbatch = config.tsamps_perbatch;
        detect_threshold = config.detect_threshold;
        num_windows = config.num_windows;
        iters_perbatch = config.iters_perbatch;
        num_loads = config.num_loads;
    }

    // Store
    {
        HLS_PROTO("store-dma");
        
        // deleted pingpong

// compute the DMA offset due to input data
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = (num_windows*window_size*tsamps_perbatch*batches_perload) * num_loads;
#else
        uint32_t store_offset = round_up(num_windows*window_size*tsamps_perbatch*batches_perload, DMA_WORD_PER_BEAT) * num_loads;
#endif
        uint32_t offset = store_offset;

        wait();
// length of data to be stored
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t length = num_windows*(neurons_perwin*(window_size+1) + window_size*(neurons_perwin+1));
#else
        // broke up this computation and added some waits in order to improve schedule
        uint32_t length_dum = num_windows*(neurons_perwin*(window_size+1) +
                                           window_size*(neurons_perwin+1));
        wait();
        uint32_t length = round_up(length_dum, DMA_WORD_PER_BEAT);
#endif
        wait();

// deleted batching since we only store at the end

        // this will only happen at the end
        this->store_compute_handshake();

        // deleted chunking - see here that the variable len from chunking is simply length
        uint32_t len = length;

// stuff that used to be in chunking loop
#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
        dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
        offset += len;

        this->dma_write_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        for (uint16_t i = 0; i < len; i++)
        {
            // Read from PLM
            sc_dt::sc_int<DATA_WIDTH> data;
            wait();

            // deleted pingpong
            data = plm_out[i];

            sc_dt::sc_bv<DATA_WIDTH> dataBv(data);

            uint16_t k = 0;
            for (k = 0; k < DMA_BEAT_PER_WORD - 1; k++)
            {
                this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                wait();
            }
            // Last beat on the bus does not require wait(), which is
            // placed before accessing the PLM
            this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
        }
#else
        for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
        {
            sc_dt::sc_bv<DMA_WIDTH> dataBv;

            // Read from PLM
            wait();
            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
            {
                HLS_UNROLL_SIMPLE;

                // deleted pingpong
                dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out[i + k];
            }
            this->dma_write_chnl.put(dataBv);
        }
#endif

// commented out chunking since we will store all outputs at once
/*
        // Chunking - we have a chunking factor of one so this only runs once
        for (int rem = length; rem > 0; rem -= PLM_OUT_WORD)
        {

            // Configure DMA transaction
            uint32_t len = rem > PLM_OUT_WORD ? PLM_OUT_WORD : rem;

            // this is where the removed stuff went
            // end of chunk
        }
*/

    }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}
