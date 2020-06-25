#include "tests/tests.h"
#include "esp_headers.hpp" // ESP-common headers

#include <stdio.h>
#include <stdlib.h>

#include <mc_scverify.h>   // Enable SCVerify

#include "sha2.h"
#include "tests/tests.h"

CCS_MAIN(int argc, char **argv)
{
    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "ESP - SHA2 [Catapult HLS C++]");
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
    ESP_REPORT_INFO(VON, "START - SHA2BYTE - monte carlo");
    errors += sha224_montecarlo();
    errors += sha256_montecarlo();
    errors += sha384_montecarlo();
    errors += sha512_montecarlo();
    ESP_REPORT_INFO(VON, "END - SHA2BYTE - monte carlo");
#endif

    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "START - SHA2BYTE - short messages");
    errors += sha224_shortmsg();
    errors += sha256_shortmsg();
    errors += sha384_shortmsg();
    errors += sha512_shortmsg();
    ESP_REPORT_INFO(VON, "END - SHA2BYTE - short messages");

    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "START - SHA2BYTE - long messages");
    errors += sha224_longmsg();
    errors += sha256_longmsg();
    errors += sha384_longmsg();
    errors += sha512_longmsg();
    ESP_REPORT_INFO(VON, "END - SHA2BYTE - long messages");

    ESP_REPORT_INFO(VON, "-----------------------------");
    ESP_REPORT_INFO(VON, "TOTAL ERRORS %d\n", errors);

    CCS_RETURN(0);
}
