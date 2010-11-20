#include <string.h>
#include <stdio.h>

int main() {
  char *buf;
  char c, *d2, *d3;
  size_t n;

  while ((buf = fgetln(stdin, &n))) {
    d2 = strchr(buf, '|');
    if (d2 == NULL) goto skip;
    *d2 = '\0';
    ++d2;
    d2 = strchr(d2+1, '/');
    if (d2 == NULL) ;
    d2 = strchr(d2+1, '/');
    if (d2 == NULL) goto skip;
    ++d2;
    d3 = strchr(d2, '|');
    if (d3 == NULL) { d2 = d3; goto skip; }
    *d3 = '\0';
    printf("%s %s\n", d2, buf);
  skip:
    if (! memchr(d2, '\n', d2-buf+n)) {
      while ((c = getc(stdin)) && c != '\n') ;
    }
  }
  return 0;
}
