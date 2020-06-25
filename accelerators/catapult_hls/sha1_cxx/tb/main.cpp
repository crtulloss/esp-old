#include "esp_headers.hpp" // ESP-common headers

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#include <mc_scverify.h>   // Enable SCVerify

#include "sha1.h"
#include "tests/tests.h"

CCS_MAIN(int argc, char **argv)
{
    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "ESP - SHA1 [Catapult HLS C++]");
#ifdef HIERARCHICAL_BLOCKS
    ESP_REPORT_INFO(VON, "      Hierarchical blocks");
#else
    ESP_REPORT_INFO(VON, "      Single block");
#endif
    ESP_REPORT_INFO(VON, "-----------------------------");

    int errors = 0;

    (void) argc; /* silent warning */
    (void) argv; /* silent warning */

#if 0
    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "START - SHA1BYTE - monte carlo");
    errors += sha1_montecarlo();
    ESP_REPORT_INFO(VON, "END - SHA1BYTE - monte carlo");
#endif

    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "START - SHA1BYTE - short messages");
    errors += sha1_shortmsg();
    ESP_REPORT_INFO(VON, "END - SHA1BYTE - short messages");

    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "START - SHA1BYTE - long messages");
    errors += sha1_longmsg();
    ESP_REPORT_INFO(VON, "END - SHA1BYTE - long messages");

    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "TOTAL ERRORS %d\n", errors);

    CCS_RETURN(0);
}
