.PHONY: all setup clean

all: python
setup: Modules/Setup

PYTHON=python
PREFIX=$(shell pwd)/install
CONF_ARGS=
MAKE_ARGS=
BUILTINS=pwd syslog mmap fcntl ctypes posix _datetime datetime _hashlib hashlib _sha1 _md5 _sha512 _sha256 _json json _crypt crypt zlib _socket socket select signal array cmath math _struct _operator _random _collections _heapq itertools _functools _elementtree _pickle _bisect unicodedata atexit
# remove _weakref because was included in core build
# remove cmath to avoid conflict with cmath
# removed testcapi due to bug (http://bugs.python.org/issue19348)
SCRIPT=
DFLAG=
CFLAGS=-static
CPPFLAGS=
LDFLAGS=-static
INCLUDE=-I/usr/include

Modules/Setup: Modules/Setup.dist add_builtins.py
	sed -e 's/#\*shared\*/\*static\*/g' Modules/Setup.dist \
	> Modules/Setup
	[ -d Modules/extras ] || mkdir Modules/extras
	$(PYTHON) add_builtins.py $(BUILTINS) $(DFLAG) -s $(SCRIPT)

Makefile: Modules/Setup
	[ -d $(PREFIX) ] || mkdir $(PREFIX)
	./configure LDFLAGS="-Wl,-no-export-dynamic -static-libgcc -static $(LDFLAGS) $(INCLUDE)" \
		CPPFLAGS="-I/usr/lib -static -fPIC $(CPPLAGS) $(INCLUDE)" LINKFORSHARED=" " \
		DYNLOADFILE="dynload_stub.o" -disable-shared \
		-prefix="$(PREFIX)" $(CONF_ARGS)

python: Modules/Setup Makefile
	make $(MAKE_ARGS)

clean:
	rm -f Makefile Modules/Setup python
