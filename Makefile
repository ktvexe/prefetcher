CFLAGS = -msse3 -msse2 --std gnu99 -O0 -Wall -g
GIT_HOOKS := .git/hooks/pre-commit
EXEC = SSE_PF SSE naive SSE_2
all: $(GIT_HOOKS) main.c $(EXEC)
SSE_PF: main.c
	$(CC) $(CFLAGS) -DSSE_PF -o $@ main.c
SSE: main.c
	$(CC) $(CFLAGS) -DSSE -o $@ main.c
SSE_2: main.c
	$(CC) $(CFLAGS) -DSSE_2 -o $@ main.c
naive: main.c
	$(CC) $(CFLAGS) -DNAIVE -o $@ main.c

run: $(EXEC)
	echo 3 |sudo tee /proc/sys/vm/drop_caches
	perf stat -r 100 -e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-store-misses,L1-dcache-prefetch-misses,L1-icache-load-misses ./naive	    
	echo 3 |sudo tee /proc/sys/vm/drop_caches
	perf stat -r 100 -e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-store-misses,L1-dcache-prefetch-misses,L1-icache-load-misses ./SSE 
	echo 3 |sudo tee /proc/sys/vm/drop_caches
	perf stat -r 100 -e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-store-misses,L1-dcache-prefetch-misses,L1-icache-load-misses ./SSE_2 
	echo 3 |sudo tee /proc/sys/vm/drop_caches
	perf stat -r 100 -e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-store-misses,L1-dcache-prefetch-misses,L1-icache-load-misses ./SSE_PF 

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo
clean:
	$(RM) $(EXEC)
