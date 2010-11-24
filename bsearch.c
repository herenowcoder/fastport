#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define D(_format, ...) fprintf(stderr, _format "\n", __VA_ARGS__)

typedef int (*compare_fptr)(const char *key, const char *var);

static FILE *f;
static const char *key;
static compare_fptr comparator = NULL;
static char *line;
static size_t linelen = 0;


static char * bsearch_loop(long p1, long p2, long *pprev) {
  D("loop p1=%ld p2=%ld", p1, p2);
  if (!(pprev && pprev[0] == p1 && pprev[1] == p2)) {
    long pprev1[2];
    pprev1[0] = p1; pprev1[1] = p2;
    fseek(f, p1 + ((p2-p1) >> 1), SEEK_SET);
    fgetln(f, &linelen);
    long p = ftell(f);
    line = fgetln(f, &linelen);
    if (line == NULL) return bsearch_loop(p1, p2, pprev1);
    int r = comparator(key, line);
    if (r < 0)
      bsearch_loop(p1, p, pprev1);
    else if (r > 0)
      bsearch_loop(ftell(f), p2, pprev1);
    else
      return strndup(line, linelen);
  } else {
    fseek(f, p1, SEEK_SET);
    while ((line = fgetln(f, &linelen)) != NULL) {
      if (comparator(key, line) == 0) return strndup(line, linelen);
    }
    return NULL;
  }
}


struct str_range {
  char *str;
  size_t n;
};

static struct str_range portpath_from_indexline(const char *s) {
  char *i, *j;
  i = strchr(s, '|');
  i = strchr(++i, '/');
  i = strchr(++i, '/');
  i = strchr(++i, '/');
  j = strchr(++i, '|');
  struct str_range r;
  r.str = i;
  r.n = j-i;
  return r;
}

static int compare_index_entry(const char *key, const char *entry) {
  const struct str_range portpath = portpath_from_indexline(entry);
  char buf[portpath.n+1];
  strncpy(buf, portpath.str, portpath.n);
  buf[portpath.n] = '\0';
  char *delim = strchr(buf, '/');
  *delim = ' ';
  int r = strcmp(key, buf);
  D("comparator key=\"%s\" var=\"%s\" r=%d", key, buf, r);
  return r;
}


char * bsearch_index(FILE *index_f, const char *index_key) {
  char keybuf[strlen(index_key)+1];
  strcpy(keybuf, index_key);
  char *delim = strchr(keybuf, '/');
  *delim = ' ';
  key = keybuf;
  f = index_f;
  comparator = &compare_index_entry;
  D("bsearch setup: key=\"%s\"", key);
  fseek(f, 0L, SEEK_END);
  return bsearch_loop(0L, ftell(f), NULL);
}

int main(int argc, const char **argv) {
  char *r = bsearch_index(fopen("/usr/ports/INDEX-8", "r"), argv[1]);
  if (r) puts(r);
  free(r);
  return r ? 0 : 1;
}
