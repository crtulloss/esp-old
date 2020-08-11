// software-only testbench for mindfuzz k-means threshold update

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
    int window_size = 1;
    int batches_perload = 1;
    int neurons_perwin = 1;
    int tsamps_perbatch = 70;
    TYPE detect_threshold = 100.0;
    int num_windows = 1;
    int iters_perbatch = 1;
    int num_loads = 13332;

    TYPE learning_rate_spike = 0.1;
    TYPE learning_rate_noise = 0.01;
    TYPE spike_weight = 0.5;
    TYPE std = 0.1;

    // setup 
    
    // some dimensions useful for array sizing
    uint32_t in_size_perload = num_windows*window_size;
    uint32_t in_size = in_size_perload*num_loads;
    uint32_t out_size_perload = num_windows*window_size*2;
    uint32_t out_size = out_size_perload*num_loads;

    // read input data into the array pasedCSV
    std::ifstream indata("kmeans/data_kmeans_scalar.csv");
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

    for (uint32_t row = 0; row < num_loads; row++) {

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

    // read output (cluster centers) data from CSV file into 2D array
    std::ifstream wdata("kmeans/kmeans_scalar.csv");
    std::string wline;
    std::vector<std::vector<std::string> > parsed_clusters;
    while(std::getline(wdata, wline)) {
        std::stringstream lineStream(wline);
        std::string cell;
        std::vector<std::string> parsedRow;
        while(std::getline(lineStream, cell, ',')) {
            parsedRow.push_back(cell);
        }

        parsed_clusters.push_back(parsedRow);
    }

    // temporary float array to store the golden output data
    TYPE gold[out_size];

    for (uint32_t row = 0; row < num_loads*2; row++) {

        uint32_t row_offset = row * num_windows * window_size;

        for (uint32_t col = 0; col < num_windows*window_size; col++) {

            // acquire 2D array element
            // there is one extra header row in the CSV
            // and one extra timestamp column
            // and one column indicating which cluster
            // add appropriate offsets to indices to ignore these
            std::string element = parsedCSV[row+1][col+2];

            // convert string to float
            stringstream sselem(element);
            TYPE float_element = 0;
            sselem >> float_element;

            // put it in the array
            gold[row_offset + col] = float_element;
        }
    }

    // this one is TYPE because it represents an actual PLM
    TYPE plm_out[out_size];

    // temporary variables for the current mean values
    TYPE mean_spike[num_windows * window_size];
    TYPE mean_noise[num_windows * window_size];
    TYPE thresh[num_windows * window_size];

    // initial values
    TYPE mean_spike_init = 4*std;
    TYPE mean_noise_init = 2*std;

    // initialize means
    for (uint16_t i = 0; i < num_windows * window_size; i++) {
        mean_spike[i] = mean_spike_init;
        mean_noise[i] = mean_noise_init;
    }

    // actual computation
    {
        // note that this num_loads refers to the number of load batches
        for (uint16_t b = 0; b < num_loads; b++)
        {

            // calculate offset due to the fact that there is no pipelined input loading
            int32_t indata_offset = in_size_perload*b;
            int32_t outdata_offset = out_size_perload*b;

            // perform a threshold update
            thresh_update(in,
                          num_windows,
                          window_size,
                          learning_rate_spike,
                          learning_rate_noise,
                          spike_weight,
                          mean_spike,
                          mean_noise,
                          thresh,
                          indata_offset);

            // store the results in the output comparison array
            // for noise
            for (uint16_t i = 0; i < num_windows * window_size; i++) {
                plm_out[outdata_offset + i] = mean_noise[i];
            }
            // for spike
            for (uint16_t i = 0; i < num_windows * window_size; i++) {
                plm_out[outdata_offset + in_size_perload + i] = mean_spike[i];
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
            //cout << "close for weight " << j << "\n";
        }
    }

    cout << "relative error > " << ERR_TH << " for " << errors << " output cluster means out of "
        << out_size << "\n";

    return 0;
}
