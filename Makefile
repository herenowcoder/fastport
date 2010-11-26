CFLAGS=		-std=c99 -Wall -O2 -pipe -g
LDFLAGS= 	

bsearch:	bsearch.c

clean:
		rm bsearch

install:	bsearch
		install -d /usr/local/libexec/fastport/
		install -s bsearch /usr/local/libexec/fastport/
		install fastport.rb /usr/local/bin/fastport

deinstall:
		rm /usr/local/bin/fastport
		rm /usr/local/libexec/fastport/bsearch
		rmdir /usr/local/libexec/fastport
