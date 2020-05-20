/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include "libesp.h"

unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
	return (sizeof(void *) / _st);
}

void *accelerator_thread( void *ptr )
{
    esp_thread_info_t *info = (esp_thread_info_t *) ptr;
	struct timespec th_start;
	struct timespec th_end;
	int rc = 0;

    printf("starting p2p device %s\n", info->devname);

    gettime(&th_start);
	switch (info->type) {
	// <<--esp-ioctl-->>
	case fftaccelerator :
		rc = ioctl(info->fd, FFTACCELERATOR_IOC_ACCESS, info->desc.fftaccelerator_desc);
		break;
	case adderaccelerator :
		rc = ioctl(info->fd, ADDERACCELERATOR_IOC_ACCESS, info->desc.adderaccelerator_desc);
		break;
	case fft :
		rc = ioctl(info->fd, FFT_IOC_ACCESS, info->desc.fft_desc);
		break;
	case adder :
		rc = ioctl(info->fd, ADDER_IOC_ACCESS, info->desc.adder_desc);
		break;
	case CounterAccelerator :
		rc = ioctl(info->fd, COUNTERACCELERATOR_IOC_ACCESS, info->desc.CounterAccelerator_desc);
		break;
	case dummy :
		rc = ioctl(info->fd, DUMMY_IOC_ACCESS, info->desc.dummy_desc);
		break;
	case sort :
		rc = ioctl(info->fd, SORT_IOC_ACCESS, info->desc.sort_desc);
		break;
	case spmv :
		rc = ioctl(info->fd, SPMV_IOC_ACCESS, info->desc.spmv_desc);
		break;
	case synth :
		rc = ioctl(info->fd, SYNTH_IOC_ACCESS, info->desc.synth_desc);
		break;
	case visionchip :
		rc = ioctl(info->fd, VISIONCHIP_IOC_ACCESS, info->desc.visionchip_desc);
		break;
	case vitbfly2 :
		rc = ioctl(info->fd, VITBFLY2_IOC_ACCESS, info->desc.vitbfly2_desc);
		break;
	}
	gettime(&th_end);
	if (rc < 0) {
		perror("ioctl");
	}
	info->hw_ns = ts_subtract(&th_start, &th_end);

	return NULL;
}

void *accelerator_thread_p2p(void *ptr)
{
    struct thread_args *args = (struct thread_args*) ptr;
    esp_thread_info_t *thread = args->info;
    unsigned nacc = args->nacc;
	int rc = 0;
    int i;

    pthread_t *threads = malloc(nacc * sizeof(pthread_t));

    printf("starting p2p thread with %d acc\n", nacc);

    for (i = 0; i < nacc; i++){
        esp_thread_info_t *info = thread + i;
        if (!info->run)
            continue;
        rc = pthread_create(&threads[i], NULL, accelerator_thread, (void*) info);
        if (rc != 0)
            perror("pthread_create");
    }

    for (i = 0; i < nacc; i++){
        esp_thread_info_t *info = thread + i;
        if (!info->run)
            continue;
        rc = pthread_join(threads[i], NULL);
        if (rc != 0)
            perror("pthread_join");
        close(info->fd);
    }
    free(threads);
    free(ptr);
    return NULL;
}

void *accelerator_thread_serial(void *ptr)
{
    struct thread_args *args = (struct thread_args*) ptr;
    esp_thread_info_t *thread = args->info;
    unsigned nacc = args->nacc;
    int i;
    for (i = 0; i < nacc; i++){
        
        struct timespec th_start;
        struct timespec th_end;
        int rc = 0;
        esp_thread_info_t *info = thread + i; 
        
        if (!info->run)
            continue;

        gettime(&th_start);
        switch (info->type) {
        // <<--esp-ioctl-->>
        case fftaccelerator :
            rc = ioctl(info->fd, FFTACCELERATOR_IOC_ACCESS, info->desc.fftaccelerator_desc);
            break;
        case adderaccelerator :
            rc = ioctl(info->fd, ADDERACCELERATOR_IOC_ACCESS, info->desc.adderaccelerator_desc);
            break;
        case fft :
            rc = ioctl(info->fd, FFT_IOC_ACCESS, info->desc.fft_desc);
            break;
        case adder :
            rc = ioctl(info->fd, ADDER_IOC_ACCESS, info->desc.adder_desc);
            break;
        case CounterAccelerator :
            rc = ioctl(info->fd, COUNTERACCELERATOR_IOC_ACCESS, info->desc.CounterAccelerator_desc);
            break;
        case dummy :
            rc = ioctl(info->fd, DUMMY_IOC_ACCESS, info->desc.dummy_desc);
            break;
        case sort :
            rc = ioctl(info->fd, SORT_IOC_ACCESS, info->desc.sort_desc);
            break;
        case spmv :
            rc = ioctl(info->fd, SPMV_IOC_ACCESS, info->desc.spmv_desc);
            break;
        case synth :
            rc = ioctl(info->fd, SYNTH_IOC_ACCESS, info->desc.synth_desc);
            break;
        case visionchip :
            rc = ioctl(info->fd, VISIONCHIP_IOC_ACCESS, info->desc.visionchip_desc);
            break;
        case vitbfly2 :
            rc = ioctl(info->fd, VITBFLY2_IOC_ACCESS, info->desc.vitbfly2_desc);
            break;
        }
        gettime(&th_end);
        if (rc < 0) {
            perror("ioctl");
        }
        info->hw_ns = ts_subtract(&th_start, &th_end);
        close(info->fd);
    }
	free(ptr);
    return NULL;
}

void *esp_alloc_policy(struct contig_alloc_params params, size_t size, contig_handle_t *handle){
    void* contig_ptr = contig_alloc_policy(params, size, handle); 
    return contig_ptr;
}

void *esp_alloc(size_t size, contig_handle_t *handle)
{
    void* contig_ptr = contig_alloc(size, handle);
    return contig_ptr;
}

static void esp_prepare(struct esp_access *esp, contig_handle_t *handle)
{
	esp->contig = contig_to_khandle(*handle);
	esp->run = true;
}

static void esp_config(esp_thread_info_t* cfg[], unsigned nthreads, unsigned *nacc)
{
	int i, j;
	for (i = 0; i < nthreads; i++) {
        unsigned len = nacc[i];
        for(j = 0; j < len; j++){
		    esp_thread_info_t *info = cfg[i] + j;
            if (!info->run)
                continue;

            switch (info->type) {
            // <<--esp-prepare-->>
            case fftaccelerator :
                esp_prepare(&info->desc.fftaccelerator_desc.esp, info->contig_handle);
                break;
            case adderaccelerator :
                esp_prepare(&info->desc.adderaccelerator_desc.esp, info->contig_handle);
                break;
            case fft :
                esp_prepare(&info->desc.fft_desc.esp, info->contig_handle);
                break;
            case adder:
                esp_prepare(&info->desc.adder_desc.esp, info->contig_handle);
                break;
            case CounterAccelerator:
                esp_prepare(&info->desc.CounterAccelerator_desc.esp, info->contig_handle);
                break;
            case dummy:
                esp_prepare(&info->desc.dummy_desc.esp, info->contig_handle);
                break;
            case sort:
                esp_prepare(&info->desc.sort_desc.esp, info->contig_handle);
                break;
            case spmv:
                esp_prepare(&info->desc.spmv_desc.esp, info->contig_handle);
                break;
            case synth:
                esp_prepare(&info->desc.synth_desc.esp, info->contig_handle);
                break;
            case visionchip:
                esp_prepare(&info->desc.visionchip_desc.esp, info->contig_handle);
                break;
            case vitbfly2:
                esp_prepare(&info->desc.vitbfly2_desc.esp, info->contig_handle);
                break;
            default :
                contig_free(*(info->contig_handle));
                die("Error: accelerator type specified for accelerator %s not supported\n", info->devname);
                break;
            }
        }
	}
}

static void print_time_info(esp_thread_info_t *info[], unsigned long long hw_ns, int nthreads, unsigned* nacc)
{
	int i, j;

	printf("  > Test time: %llu ns\n", hw_ns);
	for (i = 0; i < nthreads; i++){
	    unsigned len = nacc[i];
        for (j = 0; j < len; j ++){ 
            esp_thread_info_t* cur = info[i] + j;
            if (cur->run)
			    printf("    - %s time: %llu ns\n", cur->devname, cur->hw_ns);
        }
    }
}

void esp_run(esp_thread_info_t cfg[], unsigned nacc)
{ 
    int i;
    esp_thread_info_t **cfg_ptrs = malloc(sizeof(esp_thread_info_t*) * nacc);
    
    for (i = 0; i < nacc; i++)
        cfg_ptrs[i] = &cfg[i];
    
    esp_run_parallel(cfg_ptrs, 1, &nacc);
}

void esp_run_parallel(esp_thread_info_t* cfg[], unsigned nthreads, unsigned* nacc)
{
	int i, j;
	struct timespec th_start;
	struct timespec th_end;
	pthread_t *thread = malloc(nthreads * sizeof(pthread_t));
	int rc = 0;

    esp_config(cfg, nthreads, nacc);
    for (i = 0; i < nthreads; i++) {
        unsigned len = nacc[i];
        for (j = 0; j < len; j++){
            esp_thread_info_t *info = cfg[i] + j;
            const char *prefix = "/dev/";
            char path[70];

            if (strlen(info->devname) > 64) {
                contig_free(*(info->contig_handle));
                die("Error: device name %s exceeds maximum length of 64 characters\n", info->devname);
            }

            sprintf(path, "%s%s", prefix, info->devname);
            
            info->fd = open(path, O_RDWR, 0);
            if (info->fd < 0) {
                contig_free(*(info->contig_handle));
                die_errno("fopen failed\n");
            }
        }
	}

	gettime(&th_start);
	for (i = 0; i < nthreads; i++) {
        struct thread_args *args = malloc(sizeof(struct thread_args));;
        args->info = cfg[i];
        args->nacc = nacc[i];
        
        if (cfg[i]->desc.synth_desc.esp.p2p_store || cfg[i]->desc.synth_desc.esp.p2p_nsrcs)
            rc = pthread_create(&thread[i], NULL, accelerator_thread_p2p, (void*) args);
        else
            rc = pthread_create(&thread[i], NULL, accelerator_thread_serial, (void*) args);
        
        if(rc != 0) {
			perror("pthread_create");
	    }
	}
	
    for (i = 0; i < nthreads; i++) {
		rc = pthread_join(thread[i], NULL);
		
        if(rc != 0) {
			perror("pthread_join");
		}
	}
	
    gettime(&th_end);
	print_time_info(cfg, ts_subtract(&th_start, &th_end), nthreads, nacc);

	free(thread);
}


void esp_cleanup(contig_handle_t *handle)
{
    contig_free(*handle);
}
