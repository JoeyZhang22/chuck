DESTDIR=/usr/bin

# default target: print usage message and quit
current: 
	@echo "[chuck build]: please use one of the following configurations:"
	@echo "   make linux-alsa, make linux-jack, make linux-oss,"
	@echo "   make osx, make osx-ub, or make win32"

install:
	cp $(wildcard chuck chuck.exe) $(DESTDIR)/
	chmod 755 $(DESTDIR)/$(wildcard chuck chuck.exe)

ifneq ($(CK_TARGET),)
.DEFAULT_GOAL:=$(CK_TARGET)
ifeq ($(MAKECMDGOALS),)
MAKECMDGOALS:=$(.DEFAULT_GOAL)
endif
endif

.PHONY: osx linux-oss linux-jack linux-alsa win32 osx-rl
osx linux-oss linux-jack linux-alsa win32 osx-rl: chuck

CK_VERSION=1.3.1.0

LEX=flex
YACC=bison
CC=gcc
CXX=gcc
LD=g++

ifneq ($(CHUCK_STAT),)
CFLAGS+= -D__CHUCK_STAT_TRACK__
endif

ifneq ($(CHUCK_DEBUG),)
CFLAGS+= -g
else
CFLAGS+= -O3
endif

ifneq ($(USE_64_BIT_SAMPLE),)
CFLAGS+= -D__CHUCK_USE_64_BIT_SAMPLE__
endif

ifneq ($(CHUCK_STRICT),)
CFLAGS+= -Wall
endif

ifneq (,$(strip $(filter osx bin-dist-osx,$(MAKECMDGOALS))))
include makefile.osx
endif

ifneq (,$(strip $(filter linux-oss,$(MAKECMDGOALS))))
include makefile.oss
endif

ifneq (,$(strip $(filter linux-jack,$(MAKECMDGOALS))))
include makefile.jack
endif

ifneq (,$(strip $(filter linux-alsa,$(MAKECMDGOALS))))
include makefile.alsa
endif

ifneq (,$(strip $(filter win32,$(MAKECMDGOALS))))
include makefile.win32
endif

ifneq (,$(strip $(filter osx-rl,$(MAKECMDGOALS))))
include makefile.rl
endif

CSRCS+= chuck.tab.c chuck.yy.c util_math.c util_network.c util_raw.c \
	util_xforms.c
CXXSRCS+= chuck_absyn.cpp chuck_parse.cpp chuck_errmsg.cpp \
	chuck_frame.cpp chuck_symbol.cpp chuck_table.cpp chuck_utils.cpp \
	chuck_vm.cpp chuck_instr.cpp chuck_scan.cpp chuck_type.cpp chuck_emit.cpp \
	chuck_compile.cpp chuck_dl.cpp chuck_oo.cpp chuck_lang.cpp chuck_ugen.cpp \
	chuck_main.cpp chuck_otf.cpp chuck_stats.cpp chuck_bbq.cpp chuck_shell.cpp \
	chuck_console.cpp chuck_globals.cpp digiio_rtaudio.cpp hidio_sdl.cpp \
	midiio_rtmidi.cpp RtAudio/RtAudio.cpp rtmidi.cpp ugen_osc.cpp ugen_filter.cpp \
	ugen_stk.cpp ugen_xxx.cpp ulib_machine.cpp ulib_math.cpp ulib_std.cpp \
	ulib_opsc.cpp util_buffers.cpp util_console.cpp \
	util_string.cpp util_thread.cpp util_opsc.cpp \
	util_hid.cpp uana_xform.cpp uana_extract.cpp util_path.cpp
OBJCXXSRCS+= 

COBJS=$(CSRCS:.c=.o)
CXXOBJS=$(CXXSRCS:.cpp=.o)
OBJCXXOBJS=$(OBJCXXSRCS:.mm=.o)
OBJS=$(COBJS) $(CXXOBJS) $(OBJCXXOBJS)

# remove -arch options
CFLAGSDEPEND?=$(CFLAGS)

ifneq (,$(ARCHS))
ARCHOPTS=$(addprefix -arch ,$(ARCHS))
else
ARCHOPTS=
endif

NOTES=AUTHORS DEVELOPER PROGRAMMER README TODO COPYING INSTALL QUICKSTART \
 THANKS VERSIONS
BIN_NOTES=README.txt
DOC_NOTES=GOTO
DIST_DIR=chuck-$(CK_VERSION)
DIST_DIR_EXE=chuck-$(CK_VERSION)-exe
CK_SVN=https://chuck-dev.stanford.edu/svn/chuck/

# pull in dependency info for *existing* .o files
-include $(OBJS:.o=.d)

chuck: $(OBJS)
	$(LD) -o chuck $(OBJS) $(LDFLAGS) $(ARCHOPTS)

chuck.tab.c chuck.tab.h: chuck.y
	$(YACC) -dv -b chuck chuck.y

chuck.yy.c: chuck.lex
	$(LEX) -ochuck.yy.c chuck.lex

$(COBJS): %.o: %.c
	$(CC) $(CFLAGS) $(ARCHOPTS) -c $< -o $@
	@$(CC) -MM $(CFLAGSDEPEND) $< > $*.d

$(CXXOBJS): %.o: %.cpp
	$(CXX) $(CFLAGS) $(ARCHOPTS) -c $< -o $@
	@$(CXX) -MM $(CFLAGSDEPEND) $< > $*.d

$(OBJCXXOBJS): %.o: %.mm
	$(CXX) $(CFLAGS) -c $< -o $@
	@$(CXX) -MM $(CFLAGSDEPEND) $< > $*.d

clean: 
	@rm -f $(wildcard chuck chuck.exe) *.o *.d $(OBJS) $(patsubst %.o,%.d,$(OBJS)) \
    *~ chuck.output chuck.tab.h chuck.tab.c chuck.yy.c $(DIST_DIR){,.tgz,.zip}
	

# ------------------------------------------------------------------------------
# Distribution meta-targets
# ------------------------------------------------------------------------------

.PHONY: bin-dist-osx
bin-dist-osx: osx
# clean out old dists
	-rm -rf $(DIST_DIR_EXE){,.tgz,.zip}
# create directories
	mkdir $(DIST_DIR_EXE) $(DIST_DIR_EXE)/bin $(DIST_DIR_EXE)/doc
# copy binary + notes
	cp chuck $(addprefix ../notes/bin/,$(BIN_NOTES)) $(DIST_DIR_EXE)/bin
# copy manual + notes
	cp ../doc/manual/ChucK_manual.pdf $(addprefix ../notes/doc/,$(DOC_NOTES)) $(DIST_DIR_EXE)/doc
# copy examples
	svn export $(CK_SVN)/trunk/src/examples $(DIST_DIR_EXE)/examples &> /dev/null
#cp -r examples $(DIST_DIR_EXE)/examples
# remove .svn directories
#-find $(DIST_DIR_EXE)/examples/ -name '.svn' -exec rm -rf '{}' \; &> /dev/null
# copy notes
	cp $(addprefix ../notes/,$(NOTES)) $(DIST_DIR_EXE)
# tar/gzip
	tar czf $(DIST_DIR_EXE).tgz $(DIST_DIR_EXE)

.PHONY: bin-dist-win32
bin-dist-win32:
#	make win32
# clean out old dists
	-rm -rf $(DIST_DIR_EXE){,.tgz,.zip}
# create directories
	mkdir $(DIST_DIR_EXE) $(DIST_DIR_EXE)/bin $(DIST_DIR_EXE)/doc
# copy binary + notes
	cp Release/chuck.exe $(addprefix ../notes/bin/,$(BIN_NOTES)) $(DIST_DIR_EXE)/bin
# copy manual + notes
	cp ../doc/manual/ChucK_manual.pdf $(addprefix ../notes/doc/,$(DOC_NOTES)) $(DIST_DIR_EXE)/doc
# copy examples
	svn export $(CK_SVN)/trunk/src/examples $(DIST_DIR_EXE)/examples &> /dev/null
#cp -r examples $(DIST_DIR_EXE)/examples
# remove .svn directories
#-find $(DIST_DIR_EXE)/examples/ -name '.svn' -exec rm -rf '{}' \; &> /dev/null
# copy notes
	cp $(addprefix ../notes/,$(NOTES)) $(DIST_DIR_EXE)
# tar/gzip
	zip -q -9 -r -m $(DIST_DIR_EXE).zip $(DIST_DIR_EXE)

.PHONY: src-dist
src-dist:
# clean out old dists
	-rm -rf $(DIST_DIR){,.tgz,.zip}
# create directories
	mkdir $(DIST_DIR) $(DIST_DIR)/doc
# copy src
	svn export $(CK_SVN)/trunk/src $(DIST_DIR)/src &> /dev/null
	rm -rf $(DIST_DIR)/src/{examples,test}
# copy manual + notes
	cp ../doc/manual/ChucK_manual.pdf $(addprefix ../notes/doc/,$(DOC_NOTES)) $(DIST_DIR)/doc
# copy examples
	svn export $(CK_SVN)/trunk/src/examples $(DIST_DIR)/examples &> /dev/null
#cp -r examples $(DIST_DIR)/examples
# remove .svn directories
#-find $(DIST_DIR)/examples/ -name '.svn' -exec rm -rf '{}' \; &> /dev/null
# copy notes
	cp $(addprefix ../notes/,$(NOTES)) $(DIST_DIR)
# tar/gzip
	tar czf $(DIST_DIR).tgz $(DIST_DIR)

