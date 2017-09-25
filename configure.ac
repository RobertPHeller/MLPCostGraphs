AC_INIT(MLPCostGraphs,0.0.0,[support@deepsoft.com],MLPCostGraphs)
AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_SUBST(build)
AC_CANONICAL_TARGET
AC_SUBST(target)
AC_CONFIG_SRCDIR(MLPCostGraphs.tcl)
AM_INIT_AUTOMAKE([-Wno-portability tar-ustar])
dnl Force cross_compiling, even if it *looks* like we can run cross-built 
dnl binaries (get around wine's cleverness).
          
AC_CONFIG_MACRO_DIR([m4])

if test "x${prefix}" = "xNONE"; then
    prefix=/usr/local
fi
if test "x${exec_prefix}" = "xNONE"; then
    exec_prefix="${prefix}"
fi


BUILD_DIR=`pwd`
TOP_DIR=${BUILD_DIR}
AC_SUBST(TOP_DIR)
AC_SUBST(BUILD_DIR)
       
srcdir=`dirname $0`
cd $srcdir
SRC_DIR=`pwd`
cd $BUILD_DIR

AC_SUBST(SRC_DIR)

AC_SUBST(target)

dnl Checks for programs.

AX_PKG_DOXYGEN(1.7.4, [], [ AC_MSG_ERROR([DOXYGEN 1.7.4 is required to build.]) ])
AC_PATH_PROG(PDFLATEX,pdflatex,/bin/true)
AC_PATH_PROG(LATEX,latex,/bin/true)
AC_PATH_PROG(MAKEINDEX,makeindex,/bin/true)
AC_PATH_PROG(BIBTEX,bibtex,/bin/true)
AC_PATH_PROG(DVIPS,dvips,/bin/true)
AC_PATH_PROG(PS2PDF,ps2pdf,/bin/true)
AC_PATH_PROG(HOSTTCLKIT,tclkit)
AC_PATH_PROG(UNZIP,unzip)

TEA_INIT([3.5])
TEA_PATH_TCLCONFIG
TEA_LOAD_TCLCONFIG
TEA_PREFIX
TEA_PROG_TCLSH

if test ${cross_compiling} = "no"; then
  HOSTTCLSH=${TCLSH_PROG}
else
  AC_PATH_PROGS(HOSTTCLSH,[tclsh8.5 tclsh])
fi

dnl Check for external Tcl/Tk libraries
AX_SNIT
AX_CSV
AX_STRUCT

AC_CONFIG_FILES([Makefile \
                BuildScripts/Makefile \
                Scripts/Makefile \
                MLPCostsWithRegionalization/Makefile \
                Doxyfile
                tcldoxyfilter.sh \
                ])
AC_CONFIG_COMMANDS([default],[chmod +x tcldoxyfilter.sh])
AC_OUTPUT

