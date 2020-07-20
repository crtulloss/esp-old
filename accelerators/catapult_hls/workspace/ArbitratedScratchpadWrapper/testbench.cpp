#include "testbench.h"

#include "utils.h"

#include <iostream>

void Testbench::init() {
    rst.write(0);

    REPORT_TIME(VON, sc_time_stamp(), "Asserting reset");
    wait(2, SC_NS);
    REPORT_TIME(VON, sc_time_stamp(), "Deasserting reset");
    rst.write(1);
}

