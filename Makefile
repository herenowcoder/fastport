CFLAGS=		-Wall -O2 -pipe
LDFLAGS= 	

revindex:	revindex.c

install:	revindex
		strip revindex
		install -d /usr/local/libexec/fastport/
		install revindex /usr/local/libexec/fastport/
		install  -m 644 bsearch.rb /usr/local/libexec/fastport/
		install fastport.rb /usr/local/bin/fastport

deinstall:
		rm /usr/local/bin/fastport
		rm /usr/local/libexec/fastport/bsearch.rb
		rm /usr/local/libexec/fastport/revindex
		rmdir /usr/local/libexec/fastport
