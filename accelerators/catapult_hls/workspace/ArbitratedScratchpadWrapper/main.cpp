#include "testbench.h"

#include <testbench/nvhls_rand.h>

#include <systemc.h>

int sc_main(int argc, char *argv[]) {

    nvhls::set_random_seed();

    Testbench testbench("testbench");

    sc_report_handler::set_actions("/IEEE_Std_1666/deprecated", SC_DO_NOTHING);
    sc_report_handler::set_actions(SC_ERROR, SC_DISPLAY);

    sc_start();
    bool rc = (sc_report_handler::get_count(SC_ERROR) > 0);
    if (rc) {
        std::cout << "Info: Simulation FAIL" << std::endl;
        return 1;
    } else {
        std::cout << "Info: Simulation PASS" << std::endl;
        return 0;
    }
}
