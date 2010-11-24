CFLAGS=		-std=c99 -Wall -O2 -pipe -g
LDFLAGS= 	

bsearch:	bsearch.c

install:	
		install -d /usr/local/libexec/fastport/
		install  -m 644 bsearch.rb /usr/local/libexec/fastport/
		install fastport.rb /usr/local/bin/fastport

deinstall:
		rm /usr/local/bin/fastport
		rm /usr/local/libexec/fastport/bsearch.rb
		rmdir /usr/local/libexec/fastport
