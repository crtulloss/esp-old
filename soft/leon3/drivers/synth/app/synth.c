#include "libesp.h"
#include "synth.h"
#include "synth_cfg.h"

#define DEBUG 0
#define dprintf if(DEBUG) printf

#define NPHASES_MAX 100
#define NTHREADS_MAX 12
#define NDEV_MAX 12
#define IRREGULAR_SEED_MAX 2048

#define CFG 0
#define FIXED 1
#define AUTO 2

unsigned long long total_alloc = 0;

typedef struct accelerator_thread_info {
    int tid; 
    int ndev; 
    int chain[NDEV_MAX];
    size_t memsz;
    enum accelerator_coherence coherence_hint; 
    enum alloc_effort alloc_choice; 
    struct timespec th_start;
    struct timespec th_end; 
    contig_handle_t mem;
} accelerator_thread_info_t;

typedef struct soc_config {
    int rows; 
    int cols; 
    int nmem;
    int* mem_y;
    int* mem_x; 
    int nsynth; 
    int* synth_y;
    int* synth_x; 
    int* ddr_hops; 
} soc_config_t; 

size_t size_to_bytes (char* size){
    if (!strncmp(size, "M8", 2)){
        return 8388608;
    } else if (!strncmp(size, "M4", 2)){
        return 4194304;
    } else if (!strncmp(size, "M2", 2)){
        return 2097152;
    } else if (!strncmp(size, "M1", 2)){
        return 1048576;
    } else if (!strncmp(size, "K512", 4)){
        return 524288;
    } else if (!strncmp(size, "K256", 4)){
        return 262144;
    } else if (!strncmp(size, "K128", 4)){
        return 131072;
    } else if (!strncmp(size, "K64", 3)){
        return 65536;
    } else if (!strncmp(size, "K32", 3)){
        return 32768;
    } else if (!strncmp(size, "K16", 3)){
        return 16384;
    } else if (!strncmp(size, "K8", 2)){
        return 8192;
    } else if (!strncmp(size, "K4", 2)){
        return 4096;
    } else if (!strncmp(size, "K2", 2)){
        return 2048;
    } else if (!strncmp(size, "K1", 2)){
        return 1024;
    } else {
        return -1;
    }
}

static void read_soc_config(FILE* f, soc_config_t* soc_config){
    fscanf(f, "%d", &soc_config->rows); 
    fscanf(f, "%d", &soc_config->cols); 
    
    //get locations of memory controllers
    fscanf(f, "%d", &soc_config->nmem);
    
    int mem_loc;
    soc_config->mem_y = malloc(sizeof(int) * soc_config->nmem);
    soc_config->mem_x = malloc(sizeof(int) * soc_config->nmem);
    for (int i = 0; i < soc_config->nmem; i++){
        fscanf(f, "%d", &mem_loc); 
        soc_config->mem_y[i] = mem_loc / soc_config->cols; 
        soc_config->mem_x[i] = mem_loc % soc_config->cols; 
    }
    
    //get locations of synthetic accelerators
    fscanf(f, "%d", &soc_config->nsynth);
   
    int synth_loc;
    soc_config->synth_y = malloc(sizeof(int)*soc_config->nsynth);
    soc_config->synth_x = malloc(sizeof(int)*soc_config->nsynth);
    for (int i = 0; i < soc_config->nsynth; i++){
        fscanf(f, "%d", &synth_loc); 
        soc_config->synth_y[i] = synth_loc / soc_config->cols;  
        soc_config->synth_x[i] = synth_loc % soc_config->cols; 
    }

    //calculate hops to each ddr controller
    soc_config->ddr_hops = malloc(sizeof(int)*soc_config->nmem*soc_config->nsynth);
    for (int s = 0; s < soc_config->nsynth; s++){
        for (int m = 0; m < soc_config->nmem; m++){
            soc_config->ddr_hops[s*soc_config->nmem + m] = abs(soc_config->synth_y[s] - soc_config->mem_y[m]) + abs(soc_config->synth_x[s] - soc_config->mem_x[m]);
        }
    }  
}

static void config_threads(FILE* f, accelerator_thread_info_t **thread_info, int phase, int* nthreads, int coherence_mode, enum accelerator_coherence coherence){
    fscanf(f, "%d", nthreads); 
    dprintf("%d threads in phase %d\n", *nthreads, phase); 
    for (int t = 0; t < *nthreads; t++){
        thread_info[t] = malloc(sizeof(accelerator_thread_info_t));
        thread_info[t]->tid = t;
       
        //get number of devices and size
        fscanf(f, "%d\n", &(thread_info[t]->ndev));
        dprintf("%d devices in thread %d.%d\n", thread_info[t]->ndev, phase, t);
        
        char size[5];
        fscanf(f, "%s\n", size); 
        
        char alloc_choice[13];
        fscanf(f, "%s\n", alloc_choice);

        if (!strcmp(alloc_choice, "preferred")){
            thread_info[t]->alloc_choice = CONTIG_ALLOC_PREFERRED;
        } else if (!strcmp(alloc_choice, "lloaded")){
            thread_info[t]->alloc_choice = CONTIG_ALLOC_LEAST_LOADED;
        } else if (!strcmp(alloc_choice, "balanced")){  
            thread_info[t]->alloc_choice = CONTIG_ALLOC_BALANCED;
        }

        size_t in_size;  
        in_size = size_to_bytes(size); 

        size_t memsz = in_size; 
        unsigned int offset = 0; 

        char pattern[10];
        char coh_choice[7];
        for (int d = 0; d < thread_info[t]->ndev; d++){
            fscanf(f, "%d", &(thread_info[t]->chain[d])); 
            
            //read parameters into esp_thread_info_t     
            int devid = thread_info[t]->chain[d];
            fscanf(f, "%s", pattern); 
            if (!strncmp(pattern, "STREAMING", 9)){
                cfg_synth[devid][0].desc.synth_desc.pattern = PATTERN_STREAMING;
            } else if (!strncmp(pattern, "STRIDED", 7)){
                cfg_synth[devid][0].desc.synth_desc.pattern = PATTERN_STRIDED;
            } else if (!strncmp(pattern, "IRREGULAR", 9)){
                cfg_synth[devid][0].desc.synth_desc.pattern = PATTERN_IRREGULAR;
            }
            fscanf(f, "%d %d %d %d %d %d %d %d %s", 
                &cfg_synth[devid][0].desc.synth_desc.access_factor,
                &cfg_synth[devid][0].desc.synth_desc.burst_len,
                &cfg_synth[devid][0].desc.synth_desc.compute_bound_factor,
                &cfg_synth[devid][0].desc.synth_desc.reuse_factor,
                &cfg_synth[devid][0].desc.synth_desc.ld_st_ratio,
                &cfg_synth[devid][0].desc.synth_desc.stride_len,
                &cfg_synth[devid][0].desc.synth_desc.in_place,
                &cfg_synth[devid][0].desc.synth_desc.wr_data,
                coh_choice);
            
            if (cfg_synth[devid][0].desc.synth_desc.pattern == PATTERN_IRREGULAR)
                cfg_synth[devid][0].desc.synth_desc.irregular_seed = rand() % IRREGULAR_SEED_MAX;
        
            //calculate output size, offset, and memsize
            cfg_synth[devid][0].desc.synth_desc.in_size = in_size;  
            unsigned int out_size = (in_size >> cfg_synth[devid][0].desc.synth_desc.access_factor) 
                / cfg_synth[devid][0].desc.synth_desc.ld_st_ratio;
            cfg_synth[devid][0].desc.synth_desc.out_size = out_size;        
            cfg_synth[devid][0].desc.synth_desc.offset = offset; 
           
            dprintf("device %d has in_size %zu and out_size %zu\n", devid, in_size, out_size);
            if(cfg_synth[devid][0].desc.synth_desc.in_place == 0){
                memsz += out_size;
                offset += in_size;
            }

            unsigned int footprint = in_size >> cfg_synth[devid][0].desc.synth_desc.access_factor;

            if (!cfg_synth[devid][0].desc.synth_desc.in_place)
                footprint += out_size;
                    
            if (coherence_mode == FIXED){
                cfg_synth[devid][0].desc.synth_desc.esp.coherence = coherence;
            }
            else if (!strcmp(coh_choice, "none")){
                cfg_synth[devid][0].desc.synth_desc.esp.coherence = ACC_COH_NONE;
            }
            else if (!strcmp(coh_choice, "llc")){
                cfg_synth[devid][0].desc.synth_desc.esp.coherence = ACC_COH_LLC;
            }
            else if (!strcmp(coh_choice, "recall")){
                cfg_synth[devid][0].desc.synth_desc.esp.coherence = ACC_COH_RECALL;
            }
            else if (!strcmp(coh_choice, "full")){
                cfg_synth[devid][0].desc.synth_desc.esp.coherence = ACC_COH_FULL;
            }

            cfg_synth[devid][0].desc.synth_desc.esp.footprint = footprint; 
            cfg_synth[devid][0].desc.synth_desc.esp.in_place = cfg_synth[devid][0].desc.synth_desc.in_place; 
            cfg_synth[devid][0].desc.synth_desc.esp.reuse_factor = cfg_synth[devid][0].desc.synth_desc.reuse_factor;

            in_size = out_size; 
        }
        thread_info[t]->memsz = memsz * 4;
    }
}

static void alloc_phase(accelerator_thread_info_t **thread_info, int nthreads, soc_config_t soc_config, 
                       int alloc_mode, enum alloc_effort alloc, uint32_t **buffers){
    int largest_thread = 0;
    size_t largest_sz = 0;
    int* ddr_node_cost = malloc(sizeof(int)*soc_config.nmem);
    int preferred_node_cost;
    int preferred_node[NTHREADS_MAX];

    //determine preferred controller for each thread 
    for (int t = 0; t < nthreads; t++){
        if (thread_info[t]->memsz > largest_sz){
            largest_sz = thread_info[t]->memsz;
            largest_thread = t;
        }
    
        for (int m = 0; m < soc_config.nmem; m++){
            ddr_node_cost[m] = 0;
        }

        for (int d = 0; d < thread_info[t]->ndev; d++){
            for (int m = 0; m < soc_config.nmem; m++){
                ddr_node_cost[m] += soc_config.ddr_hops[thread_info[t]->chain[d]*soc_config.nmem + m];
            }
        }

        preferred_node_cost = ddr_node_cost[0];
        preferred_node[t] = 0;
        for (int m = 1; m < soc_config.nmem; m++){
            if (ddr_node_cost[m] < preferred_node_cost){
                preferred_node_cost = ddr_node_cost[m];
                preferred_node[t] = m;
            }
        }
    }
    
    //set policy
    for (int i = 0; i < nthreads; i++){
        struct contig_alloc_params params; 

        if (alloc_mode == CFG){
            params.policy = thread_info[i]->alloc_choice;
        } 
        else if (alloc_mode == FIXED){
            params.policy = alloc;
        }
        // AUTO
        else if (nthreads < 3){
            params.policy = CONTIG_ALLOC_BALANCED;
            params.pol.balanced.threshold = 4;
            params.pol.balanced.cluster_size = 1;
        } else if (i == largest_thread){
            params.policy = CONTIG_ALLOC_PREFERRED;
            params.pol.first.ddr_node = preferred_node[largest_thread];
        } else {
            params.policy = CONTIG_ALLOC_LEAST_LOADED;
            params.pol.lloaded.threshold = 4;
        }

        if (alloc_mode == CFG || alloc_mode == FIXED){
            if (params.policy == CONTIG_ALLOC_PREFERRED){
                params.pol.first.ddr_node = preferred_node[i]; 
            } else if (params.policy == CONTIG_ALLOC_BALANCED){
                params.pol.balanced.threshold = 4;
                params.pol.balanced.cluster_size = 1;
            } else if (params.policy == CONTIG_ALLOC_LEAST_LOADED){
                params.pol.lloaded.threshold = 4; 
            }
        }

        total_alloc += thread_info[i]->memsz;
        buffers[i] = (uint32_t *) esp_alloc_policy(params, thread_info[i]->memsz, &(thread_info[i]->mem));  
        if ( buffers[i] == NULL){
            die_errno("error: cannot allocate %zu contig bytes", thread_info[i]->memsz);   
        }

        for (int acc = 0; acc < thread_info[i]->ndev; acc++){
            int devid = thread_info[i]->chain[acc];
            cfg_synth[devid][0].desc.synth_desc.esp.alloc_policy = params.policy; 
            cfg_synth[devid][0].desc.synth_desc.esp.ddr_node = contig_to_most_allocated(thread_info[i]->mem);
        }
    }
    free(ddr_node_cost);
}

//thread that runs 1 accelerator
void *acc_chain(void *ptr){
    accelerator_thread_info_t *thread = (accelerator_thread_info_t *) ptr; 

    gettime(&thread->th_start); 

    for (int acc = 0; acc < thread->ndev; acc++){
        dprintf("starting accelerator %d\n", thread->chain[acc]);
        esp_run(cfg_synth[thread->chain[acc]], 1, &thread->mem);
    }

    gettime(&thread->th_end);

    return NULL;
}

static int validate_buffer(accelerator_thread_info_t *thread_info, uint32_t *buf){
    int errors = 0; 
    for (int i = 0; i < thread_info->ndev; i++){
            
        int devid = thread_info->chain[i];
        int offset = cfg_synth[devid][0].desc.synth_desc.offset;
        int in_size = cfg_synth[devid][0].desc.synth_desc.in_size;
        int out_size = cfg_synth[devid][0].desc.synth_desc.out_size;
        int in_place = cfg_synth[devid][0].desc.synth_desc.in_place;
        int wr_data = cfg_synth[devid][0].desc.synth_desc.wr_data;
        
        int next_in_place, next_devid;
        if (i != thread_info->ndev - 1){
           next_devid = thread_info->chain[i+1];
           next_in_place = cfg_synth[next_devid][0].desc.synth_desc.in_place;
           if (next_in_place)
               continue;
        }

        if (!in_place)
            offset += in_size; 
        
        for (int j = offset; j < offset + out_size; j++){
            if (buf[j] != wr_data){
                errors++;
            }
        }
    }
    return errors;
}

static void free_phase(accelerator_thread_info_t **thread_info, int nthreads){
    for (int i = 0; i < nthreads; i++){
        esp_cleanup(&thread_info[i]->mem); 
        free(thread_info[i]);
    }
}

int main (int argc, char** argv)
{
    srand(time(NULL));

    //command line args
    FILE* f;
    if (argc >= 2)
        f = fopen(argv[1], "r");
    else
        f = fopen("synth_cfg.txt", "r");
   
    enum accelerator_coherence coherence; 
    enum alloc_effort alloc; 
    int coherence_mode, alloc_mode; 

    if (argc != 4){
        printf("Usage: ./synth.exe file coherence alloc\n");
    }
    
    if (!strcmp(argv[2], "none")){
        coherence_mode = FIXED;
        coherence = ACC_COH_NONE;
    }
    else if (!strcmp(argv[2], "llc")){
        coherence_mode = FIXED;
        coherence = ACC_COH_LLC;
    }
    else if (!strcmp(argv[2], "recall")){
        coherence_mode = FIXED;
        coherence = ACC_COH_RECALL;
    }
    else if (!strcmp(argv[2], "full")){
        coherence_mode = FIXED;
        coherence = ACC_COH_FULL;
    }
    else if (!strcmp(argv[2], "auto")){
        coherence_mode = FIXED;
        coherence = ACC_COH_AUTO;
    }
    else if (!strcmp(argv[2], "cfg")){
        coherence_mode = CFG;
    }
    else{
        printf("Valid coherence choices include none, llc, recall, full, auto, or cfg\n");
        return 1;
    }

    if (!strcmp(argv[3], "preferred")){
        alloc_mode = FIXED;
        alloc = CONTIG_ALLOC_PREFERRED;
    }
    else if (!strcmp(argv[3], "lloaded")){
        alloc_mode = FIXED;
        alloc = CONTIG_ALLOC_LEAST_LOADED;
    }
    else if (!strcmp(argv[3], "balanced")){
        alloc_mode = FIXED;
        alloc = CONTIG_ALLOC_BALANCED;
    }
    else if (!strcmp(argv[3], "auto")){
        alloc_mode = AUTO;
        alloc = ACC_COH_AUTO;
    }
    else if (!strcmp(argv[3], "cfg")){
        alloc_mode = CFG;
    }
    else{
        printf("Valid alloc choices include preferred, lloaded, balanced, auto, and cfg\n");
        return 1;
    }

    soc_config_t* soc_config = malloc(sizeof(soc_config_t)); 
    read_soc_config(f, soc_config);
    
    //get phases
    int nphases; 
    fscanf(f, "%d\n", &nphases); 
    dprintf("%d phases\n", nphases);
    
    struct timespec th_start;
    struct timespec th_end;
    unsigned long long hw_ns = 0, hw_ns_total = 0; 
    float hw_s = 0, hw_s_total = 0; 
    
    int nthreads;
    accelerator_thread_info_t *thread_info[NPHASES_MAX][NTHREADS_MAX];
    pthread_t threads[NTHREADS_MAX];
    uint32_t *buffers[NTHREADS_MAX];
    
    //loop over phases - config, alloc, spawn thread, validate, and free
    for (int p = 0; p < nphases; p++){
        config_threads(f, thread_info[p], p, &nthreads, coherence_mode, coherence); 
        alloc_phase(thread_info[p], nthreads, *soc_config, alloc_mode, alloc, buffers); 
        
        gettime(&th_start);
        
        for (int t = 0; t < nthreads; t++){
            if (pthread_create(&threads[t], NULL, acc_chain, (void*) thread_info[p][t]))
                die_errno("pthread: cannot created thread %d", t);
        }   
       
        for (int t = 0; t < nthreads; t++){
            if (pthread_join(threads[t], NULL))
                die_errno("pthread: cannot join thread %d", t);
        }

        gettime(&th_end); 
        for (int t = 0; t < nthreads; t++){
            int errors = validate_buffer(thread_info[p][t], buffers[t]);
            if (errors)
                printf("[FAIL] Thread %d.%d : %d errors\n", p, t, errors);
            else 
                printf("[PASS] Thread %d.%d\n", p, t);  
        }
        
        hw_ns = ts_subtract(&th_start, &th_end);
        hw_ns_total += hw_ns; 
        hw_s = (float) hw_ns / 1000000000;

        sleep(1); 
        printf("PHASE.%d %.4f s\n", p, hw_s);
        sleep(1);
        
        free_phase(thread_info[p], nthreads);
    }
    hw_s_total = (float) hw_ns_total / 1000000000;
    printf("TOTAL %.4f s\n", hw_s_total); 
    
    free(soc_config->mem_y);
    free(soc_config->mem_x);
    free(soc_config->synth_y);
    free(soc_config->synth_x);
    free(soc_config->ddr_hops);
    free(soc_config);
    fclose(f);
    
    return 0; 
}
