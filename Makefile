CFLAGS=		-Wall -O2 -pipe
LDFLAGS= 	

revindex:	revindex.c

install:	revindex
		strip revindex
		install -d /usr/local/libexec/fastport/
		install revindex /usr/local/libexec/fastport/
		install  -m 644 bsearch.rb /usr/local/libexec/fastport/
		install fastport.rb /usr/local/bin/fastport
