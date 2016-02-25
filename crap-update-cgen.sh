SRC_SUPPORT="cgen cpu COPYING COPYING3 COPYING.LIB \
             COPYING3.LIB COPYING.NEWLIB COPYING.LIBGLOSS \
             ChangeLog MAINTAINERS Makefile.def Makefile.in \
             Makefile.tpl README README-maintainer-mode compile \
             config config-ml.in config.guess config.if \
             config.rpath config.sub configure configure.ac \
             configure.in contrib depcomp etc gettext.m4 \
             install-sh lt~obsolete.m4 ltgcc.m4 ltsugar.m4 \
             ltversion.m4 ltoptions.m4 libtool.m4 ltcf-c.sh \
             ltcf-cxx.sh ltcf-gcj.sh ltconfig ltmain.sh \
             makefile.vms missing mkdep mkinstalldirs \
             move-if-change setup.com src-release symlink-tree \
             ylwrap"

crap-clone -z9 :pserver:anoncvs@sourceware.org:/cvs/src src $(for x in $SRC_SUPPORT; do echo "-d $x"; done)
