#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>

#define D(_format, ...) fprintf(stderr, _format "\n", __VA_ARGS__)

typedef int (*compare_fptr)(const char *key, const char *var, size_t len);

static const char *mem;
static size_t memsize;
static const char *key;
static compare_fptr comparator = NULL;

struct strsub {
  const char *s;
  size_t n;
};

const struct strsub NULL_RANGE = {.s=NULL, .n=0};


static struct strsub bsearch_loop(long p1, long p2) {
  if (p1 >= p2) return NULL_RANGE;
  long phalf, p, pn, linesize;
  const char *lowerb, *upperb;
  int r;
  phalf = p1 + (p2 - p1)/2;
  lowerb = memrchr(mem + p1, '\n', phalf - p1);
  p = lowerb ? lowerb - mem + 1 : p1;
  upperb = memchr(mem + phalf, '\n', memsize - phalf);
  if (!upperb) exit(EX_DATAERR);
  pn = upperb - mem + 1;
  linesize = pn - p;
  r = comparator(key, mem + p, linesize);
  if (r < 0)
    return bsearch_loop(p1, p);
  else if (r > 0)
    return bsearch_loop(pn, p2);
  else
    return (struct strsub){.s = mem + p, .n = linesize};
}


#define CHK(expr) if(!(expr)) goto err;

static struct strsub portpath_from_indexline(const char *s, size_t len) 
{
  const char *i, *j;
  CHK(i = memchr(s, '|', len));
  CHK(i = memchr(++i, '/', len-(i-s)));
  CHK(i = memchr(++i, '/', len-(i-s)));
  CHK(i = memchr(++i, '/', len-(i-s)));
  CHK(j = memchr(++i, '|', len-(i-s)));
  return (struct strsub){.s = i, .n = j-i};
 err:
  return NULL_RANGE;
}

static int compare_index_entry(const char *key, const char *entry, size_t len)
{
  const struct strsub portpath = portpath_from_indexline(entry, len);
  if (!portpath.s) exit(EX_DATAERR);
  char buf[portpath.n+1];
  strncpy(buf, portpath.s, portpath.n);
  buf[portpath.n] = '\0';
  char *delim = strchr(buf, '/');
  *delim = ' ';
  return strcmp(key, buf);
}


struct strsub bsearch_index(const char *index_mem, size_t index_size, 
			    const char *index_key) 
{
  char keybuf[strlen(index_key)+1];
  strcpy(keybuf, index_key);
  char *delim = strchr(keybuf, '/');
  if (delim) *delim = ' ';
  key = keybuf;
  mem = index_mem;
  memsize = index_size;
  comparator = &compare_index_entry;
  return bsearch_loop(0L, index_size);
}

#include <sys/mman.h>
#include <sys/stat.h>

int main(int argc, char **argv) {
  FILE *f = fopen("/usr/ports/INDEX-8", "r");
  int fd = fileno(f);
  struct stat st;
  fstat(fd, &st);
  char *mem = mmap(0, st.st_size, PROT_READ, 0, fd, 0);
  char *line;
  size_t linelen;
  while ((line = fgetln(stdin, &linelen))) {
    line[linelen-1] = '\0';
    struct strsub r = bsearch_index(mem, st.st_size, line);
    if (r.s) {
      char buf[r.n+1];
      strncpy(buf, r.s, r.n);
      buf[r.n] = '\0';
      fputs(buf, stdout);
    } else
      fputs("NOT_FOUND\n", stdout);
    fflush(stdout);
  }
  munmap(mem, st.st_size);
  fclose(f);
  return 0;
}
