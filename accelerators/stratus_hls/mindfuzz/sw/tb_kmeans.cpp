// software-only testbench for mindfuzz detection and backprop kernel

// standard includes
#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <math.h>
#include <iomanip>

// mindfuzz config parameters
#define TYPE float
// magic numbers used for array sizing
#define CONST_NUM_WINDOWS 7
#define CONST_WINDOW_SIZE 4
#define CONST_NEURONS_PERWIN 1
// defines whether we use bias of not
//#define do_bias

// PLM access macros
#define a_write(x) x
#define a_read(x) x
// for hw version: a_write(x) fp2int<TYPE, WORD_SIZE>(x)
// for hw version: a_read(x) int2fp<TYPE, WORD_SIZE>(x)

using namespace std;

// mindfuzz includes
#include "mindfuzz_functions.hpp"

int main()
{
    // for precision of outputs
//    cout << std::fixed;

    // basic config params
    bool do_relu = false;
    int window_size = 4;
    int batches_perload = 1;
    int neurons_perwin = 1;
    int tsamps_perbatch = 70;
    TYPE detect_threshold = 100.0;
    int num_windows = 7;
    int iters_perbatch = 1;
    int num_loads = 500;
    // 2 from error function, 1e-6 is learning rate, scale by batch and window size
    TYPE learning_rate = 1 * 0.000001 / tsamps_perbatch / window_size;
    TYPE learning_rate_scaled = learning_rate;

    cout << "learning rate is " << learning_rate << "\n";

    // setup 
    
    // total size of a load batch is useful for relevancy check
    uint32_t total_tsamps = tsamps_perbatch * batches_perload;

    // some dimension computation useful for backprop
    uint32_t input_dimension = window_size;
    uint32_t output_dimension = input_dimension;
    uint32_t layer1_dimension = neurons_perwin;

    uint32_t W2_size = num_windows*output_dimension*layer1_dimension;
    uint32_t W1_size = num_windows*layer1_dimension*input_dimension;
    uint32_t B2_size = num_windows*output_dimension;
    uint32_t B1_size = num_windows*layer1_dimension;

    // some dimensions useful for array sizing
    uint32_t in_size_perload = num_windows*window_size*tsamps_perbatch*batches_perload;
    uint32_t in_size = in_size_perload*num_loads;
    uint32_t out_size = W2_size + W1_size;
#ifdef do_bias
    out_size += B2_size + B1_size;
#endif

    // read input data into the array pasedCSV
    std::ifstream indata("m1/data5.csv");
    std::string line;
    std::vector<std::vector<std::string> > parsedCSV;
    while(std::getline(indata, line)) {
        std::stringstream lineStream(line);
        std::string cell;
        std::vector<std::string> parsedRow;
        while(std::getline(lineStream, cell, ',')) {
            parsedRow.push_back(cell);
        }

        parsedCSV.push_back(parsedRow);
    }

    // move the input data to an array
    TYPE in[in_size];

    for (uint32_t row = 0; row < num_loads*batches_perload*tsamps_perbatch; row++) {

        uint32_t row_offset = row * num_windows * window_size;

        for (uint32_t col = 0; col < num_windows*window_size; col++) {

            // acquire 2D array element
            // there is one extra header row in the CSV
            // and one extra timestamp column
            // add one to indices to ignore these
            std::string element = parsedCSV[row+1][col+1];

            // convert string to float
            stringstream sselem(element);
            TYPE float_element = 0;
            sselem >> float_element;

            // put it in the array
            in[row_offset + col] = float_element;
        }
    }

    // read output (weight) data from CSV file into 1D array
    std::ifstream wdata("m1/weights5.csv");
    std::string wline;
    std::vector<std::vector<std::string> > parsed_weights;
    while(std::getline(wdata, wline)) {
        std::stringstream lineStream(wline);
        std::string cell;
        std::vector<std::string> parsedRow;
        while(std::getline(lineStream, cell, ',')) {
            parsedRow.push_back(cell);
        }

        parsed_weights.push_back(parsedRow);
    }

    // temporary float array to store the golden output data
    TYPE gold[out_size];

    for (uint32_t elem = 0; elem < W1_size; elem++) {

        std::string element = parsed_weights[elem + 1][2];

        // convert string to float
        stringstream sselem(element);
        TYPE float_element = 0;
        sselem >> float_element;
            
        // put it in the array
        gold[elem] = float_element;
    }
    for (uint32_t elem = 0; elem < W2_size; elem++) {

        std::string element = parsed_weights[elem + 1][3];

        // convert string to float
        stringstream sselem(element);
        TYPE float_element = 0;
        sselem >> float_element;
            
        // put it in the array
        gold[W1_size + elem] = float_element;
    }
#ifdef do_bias
    //TODO
#endif

    // this one is TYPE because it represents an actual PLM
    // TODO straight definition vs new
    TYPE plm_out[out_size];

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
                a_write(initial_weight);
        }
        // initialize W2
        for (uint32_t weight = 0; weight < W2_size; weight++) {
            plm_out[plm_offset_W2 + weight] =
                a_write(initial_weight);
        }
#ifdef do_bias
        // initialize B1
        for (uint32_t weight = 0; weight < B1_size; weight++) {
            plm_out[plm_offset_B1 + weight] =
                a_write(initial_bias);
        }
        // initialize B2
        for (uint32_t weight = 0; weight < B2_size; weight++) {
            plm_out[plm_offset_B2 + weight] =
                a_write(initial_bias);
        }
#endif
    }

    // to keep track of relevancy 
    bool flag[num_windows];

    // actual computation
    {
        // note that this num_loads refers to the number of load batches
        for (uint16_t b = 0; b < num_loads; b++)
        {

            // no-chunk code
            // see below for old code with chunking

            // calculate offset due to the fact that there is no pipelined input loading
            int32_t indata_offset = in_size_perload*b;

            // run relevancy check
            // this will update the flag array to reflect
            // the training relevance of each window
            //cout << "relevant\n";

            relevant(in,
                     total_tsamps,
                     num_windows,
                     window_size,
                     flag,
                     detect_threshold,
                     indata_offset);

            //cout << "backprop\n";

            // run backprop for each compute batch in this load batch
            for (uint16_t batch = 0; batch < batches_perload; batch++) {

                //ESP_REPORT_INFO("batch %d", b*batches_perload + batch);
                // pass relevant parameters like sizes, flag, and pingpong
                // backprop will access weights, training data, biases directly (they are in PLMs)
                backprop(in,
                         plm_out,
                         do_relu,
                         learning_rate,
                         learning_rate_scaled,
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
                         indata_offset);

                // this compute batch done
            }
            // this piece of indata (load_batch) done
        }
        // all batches done (all backprop iterations complete)
        // we only store once, once all backprop iterations are complete
    }

    // validate
    
    // Check for mismatches
    uint32_t errors = 0;
    const TYPE ERR_TH = 0.05;

    for (int j = 0; j < out_size; j++) {
        cout << std::setprecision(12) << "gold " << gold[j] << "\tout " << plm_out[j] << "\n";
        if ((fabs(gold[j] - plm_out[j]) / fabs(gold[j])) > ERR_TH) {
            errors++;
        }
        else {
            cout << "close for weight " << j << "\n";
        }
    }

    cout << "relative error > " << ERR_TH << " for " << errors << " output weights out of "
        << out_size << "\n";

    return 0;
}
