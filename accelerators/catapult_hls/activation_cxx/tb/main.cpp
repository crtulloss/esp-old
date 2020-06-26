//#include "../inc/espacc_config.h"
//#include "../inc/espacc.h"

#include <cstdlib>
#include <cstdio>

#include "tests.hpp"

#include <mc_scverify.h>   // Enable SCVerify

CCS_MAIN(int argv, char **argc) {
    ESP_REPORT_INFO(VON, "-----------------------------------");
    ESP_REPORT_INFO(VON, "ESP - Activation [Catapult HLS C++]");
#ifdef HIERARCHICAL_BLOCKS
    ESP_REPORT_INFO(VON, "      Hierarchical blocks");
#else
    ESP_REPORT_INFO(VON, "      Single block");
#endif
    ESP_REPORT_INFO(VON, "-----------------------------------");

    unsigned errors = 0;

    // Testbench return value (0 = PASS, non-0 = FAIL)
    int rc = 0;

    errors += softmax_tb();

    if (errors > 0) {
        ESP_REPORT_INFO(VON, "Validation: FAIL (errors %u / total %u)", errors, PLM_SIZE);
        rc = 1;
    } else {
        ESP_REPORT_INFO(VON, "Validation: PASS");
        rc = 0;
    }
    ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, PLM_SIZE);
    ESP_REPORT_INFO(VON, "-----------------");

    CCS_RETURN(rc);
}
