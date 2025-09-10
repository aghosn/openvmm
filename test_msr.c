#define _GNU_SOURCE
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#define REPEAT 10000

int main(void) {
    const uint32_t msr = 0x638;
    struct timespec start, end;
    int fd = open("/dev/cpu/0/msr", O_RDONLY);
    if (fd < 0) { perror("open"); return 1; }

    uint64_t value;
    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 0; i < REPEAT; i++) {
        ssize_t n = pread(fd, &value, sizeof(value), msr);
        if (n < 0) {
            perror("pread");
            return 1;
        }
    }
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    double elapsed = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    elapsed /= (double) REPEAT;
    
    printf("Read MSR 0x%x: 0x%lx\n", msr, value);
    printf("time per op seems to be %f usecs\n", elapsed * 1e6);
    
    return 0;
}

