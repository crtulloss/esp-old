#ifndef __UTILS_H__
#define __UTILS_H__

//#include <assert.h>
//#include <stdint.h>
//#include <stdbool.h>

#include "esp_headers.hpp" // ESP-common headers

// These constants are used to distinguish the different types of
// tests from the NIST Cryptographic Algorithm Validation Program.

#define SHA_MONTECARLO     1
/* cavp_data.s --> seed   */
/* cavp_data.d --> digest */

#define SHA_SHORTMSG       2
#define SHA_LONGMSG        3
/* cavp_data.l --> length  */
/* cavp_data.m --> message */
/* cavp_data.d --> digest  */

// The following struct contains information about the test vectors.
// Not all the fields are used all the times. Check above to see the
// fields that are used depending on the specific test being run.

typedef struct {

    /* Total number of tests */
    unsigned tot_tests;

    /* Length */
    uint32_t *l;

    /* Message */
    uint8_t **m;

    /* Digest */
    uint8_t **d;

	/* Seed */
	uint8_t *s;

} cavp_data;

void parse_cavp(cavp_data *cavp, const char *filename, uint8_t sel)
{
    char buf[3];
    char *token;
    size_t len = 0;
    unsigned i, j = 0;
    char *line = NULL;

    FILE *file = fopen(filename, "r");

    if (file == NULL)
    {
        fprintf(stderr, "Error: %s cannot be open\n", filename);
        exit(1);
    }

    cavp->l = NULL;
    cavp->m = NULL;
    cavp->d = NULL;
    cavp->s = NULL;
    cavp->tot_tests = 0;

    if (sel == SHA_MONTECARLO)
    {
        while (getline(&line, &len, file) != -1)
        {
            if (strstr(line, "Seed ="))
            {
                buf[2] = '\0';
                token = strtok(line, " =\n");
                token = strtok(NULL, " =\n");

		        cavp->s  = (uint8_t*) malloc(sizeof(uint8_t) * (strlen(token) - 1) / 2);
                cavp->d  = (uint8_t**) malloc(sizeof(uint8_t*) * 100);

                for (i = 0, j = 0; i < strlen(token) - 1; i += 2, j += 1)
                {
                    buf[0] = token[i + 0];
                    buf[1] = token[i + 1];
                    (cavp->s)[j] = strtoul(buf, NULL, 16);
                }
            }
            else if (strstr(line, "MD ="))
            {
                buf[2] = '\0';
                token = strtok(line, " =\n");
                token = strtok(NULL, " =\n");

 	            cavp->tot_tests += 1;

 	            cavp->d[cavp->tot_tests - 1] = (uint8_t*) malloc(
                        sizeof(uint8_t) * (strlen(token) - 1) / 2);

                for (i = 0, j = 0; i < strlen(token) - 1; i += 2, j += 1)
                {
                    buf[0] = token[i + 0];
                    buf[1] = token[i + 1];
                    (cavp->d)[cavp->tot_tests - 1][j] = strtoul(buf, NULL, 16);
                }
            }

            len = 0;
            free(line);
            line = NULL;
        }
    }
    else if (sel == SHA_SHORTMSG ||
             sel == SHA_LONGMSG)
    {
        while (getline(&line, &len, file) != -1)
        {
            if (strstr(line, "Len ="))
            {
                token = strtok(line, " =\n");
                token = strtok(NULL, " =\n");

                cavp->tot_tests += 1;
                cavp->l = (uint32_t*) realloc(cavp->l, cavp->tot_tests * sizeof(uint32_t));
                cavp->m = (uint8_t**) realloc(cavp->m, cavp->tot_tests * sizeof(uint8_t*));
                cavp->d = (uint8_t**) realloc(cavp->d, cavp->tot_tests * sizeof(uint8_t*));

                cavp->l[cavp->tot_tests - 1] = strtoul(token, NULL, 10);
            }
            else if (strstr(line, "Msg ="))
            {
                buf[2] = '\0';
                token = strtok(line, " =\n");
                token = strtok(NULL, " =\n");

                cavp->m[cavp->tot_tests - 1] = (uint8_t*) malloc(
                        sizeof(uint8_t) * (strlen(token) - 1) / 2);

                for (i = 0, j = 0; i < strlen(token) - 1; i += 2, j += 1)
                {
                    buf[0] = token[i + 0];
                    buf[1] = token[i + 1];
                    (cavp->m)[cavp->tot_tests - 1][j] = strtoul(buf, NULL, 16);
                }
            }
            else if (strstr(line, "MD ="))
            {
                buf[2] = '\0';
                token = strtok(line, " =\n");
                token = strtok(NULL, " =\n");

		    	cavp->d[cavp->tot_tests - 1] = (uint8_t*) malloc(
                        sizeof(uint8_t) * (strlen(token) - 1) / 2);

                for (i = 0, j = 0; i < strlen(token) - 1; i += 2, j += 1)
                {
                    buf[0] = token[i + 0];
                    buf[1] = token[i + 1];
                    (cavp->d)[cavp->tot_tests - 1][j] = strtoul(buf, NULL, 16);
                }
            }

            len = 0;
            free(line);
            line = NULL;
        }
    }

    fclose(file);
    free(line);
}

int eval_cavp(cavp_data *cavp, uint8_t *buffer, uint32_t len, int test,
        int sel, bool verbose)
{
    unsigned k = 0;
    int correct = 1;

    (void) sel; /* silent warning */

    for (k = 0; k < len; ++k)
        if (buffer[k] != cavp->d[test][k])
            correct = 0;

    if (verbose)
    {
        printf("-----------------------------------------------------------\n");

        printf("d: ");
        for (k = 0; k < len; ++k)
            printf("%02x ", cavp->d[test][k].to_uint());
        printf("\n");

        printf("b: ");
        for (k = 0; k < len; ++k)
            printf("%02x ", buffer[k].to_uint());
        printf("\n");

        printf("test: %s\n", (correct == 1)? "succeeded" : "failed");

        printf("-----------------------------------------------------------\n");
    }

    return correct;
}

void free_cavp(cavp_data *cavp, int sel)
{
    unsigned i = 0;

    if (sel == SHA_MONTECARLO)
    {
        free(cavp->s);
        for (i = 0; i < cavp->tot_tests; ++i)
            free(cavp->d[i]);
        free(cavp->d);
    }
    else if (sel == SHA_SHORTMSG   ||
             sel == SHA_LONGMSG)
    {
        free(cavp->l);
        for (i = 0; i < cavp->tot_tests; ++i)
            free(cavp->m[i]);
        free(cavp->m);
        for (i = 0; i < cavp->tot_tests; ++i)
            free(cavp->d[i]);
        free(cavp->d);
    }
}

#endif /* __UTILS_H__ */
