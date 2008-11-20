# Makefile to build the composite D runtime library for Linux
# Designed to work with GNU make
# Targets:
#	make
#		Same as make all
#	make lib
#		Build the runtime library
#   make doc
#       Generate documentation
#	make clean
#		Delete unneeded files created by build process

LIB_BASE=libdruntime-dmd
LIB_BUILD=
LIB_TARGET=$(LIB_BASE)$(LIB_BUILD).a
LIB_MASK=$(LIB_BASE)*.a
DUP_TARGET=libdruntime$(LIB_BUILD).a
DUP_MASK=libdruntime*.a
MAKE_LIB=lib

DIR_CC=common
DIR_RT=compiler/dmd
DIR_GC=gc/basic

CP=cp -f
RM=rm -f
MD=mkdir -p

CC=gcc
LC=$(AR) -qsv
DC=dmd

LIB_DEST=../lib

ADD_CFLAGS=-m32
ADD_DFLAGS=

targets : lib doc
all     : lib doc

######################################################

ALL_OBJS=

######################################################

ALL_DOCS=

######################################################

unittest :
	make -fdmd-posix.mak lib MAKE_LIB="unittest"
	dmd -unittest main ../import/core/stdc/stdarg -defaultlib="$(DUP_TARGET)" -debuglib="$(DUP_TARGET)"
	$(RM) stdarg.o
	main

release :
	make -fdmd-posix.mak lib MAKE_LIB="release"

debug :
	make -fdmd-posix.mak lib MAKE_LIB="debug" LIB_BUILD="-d"

######################################################

lib : $(ALL_OBJS)
	make -C $(DIR_CC) -fposix.mak $(MAKE_LIB) DC=$(DC) ADD_DFLAGS="$(ADD_DFLAGS)" ADD_CFLAGS="$(ADD_CFLAGS)"
	make -C $(DIR_RT) -fposix.mak $(MAKE_LIB) DC=$(DC) ADD_DFLAGS="$(ADD_DFLAGS)" ADD_CFLAGS="$(ADD_CFLAGS)"
	make -C $(DIR_GC) -fposix.mak $(MAKE_LIB) DC=$(DC) ADD_DFLAGS="$(ADD_DFLAGS)" ADD_CFLAGS="$(ADD_CFLAGS)"
	$(RM) $(LIB_TARGET)
	$(LC) $(LIB_TARGET) `find $(DIR_CC) -name "*.o" | xargs echo`
	$(LC) $(LIB_TARGET) `find $(DIR_RT) -name "*.o" | xargs echo`
	$(LC) $(LIB_TARGET) `find $(DIR_GC) -name "*.o" | xargs echo`
	$(RM) $(DUP_TARGET)
	$(CP) $(LIB_TARGET) $(DUP_TARGET)

doc : $(ALL_DOCS)
	make -C $(DIR_CC) -fposix.mak doc DC=$(DC)
	make -C $(DIR_RT) -fposix.mak doc DC=$(DC)
	make -C $(DIR_GC) -fposix.mak doc DC=$(DC)

######################################################

clean :
	find . -name "*.di" | xargs $(RM)
	$(RM) $(ALL_OBJS)
	$(RM) $(ALL_DOCS)
	make -C $(DIR_CC) -fposix.mak clean
	make -C $(DIR_RT) -fposix.mak clean
	make -C $(DIR_GC) -fposix.mak clean
	$(RM) $(LIB_MASK)
	$(RM) $(DUP_MASK)
	$(RM) main main.o

install :
	make -C $(DIR_CC) -fposix.mak install
	make -C $(DIR_RT) -fposix.mak install
	make -C $(DIR_GC) -fposix.mak install
	$(CP) $(LIB_MASK) $(LIB_DEST)/.
	$(CP) $(DUP_MASK) $(LIB_DEST)/.
