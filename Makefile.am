##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Sep 22 16:32:17 2017
#  Last Modified : <170925.1528>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
#
#    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
##############################################################################

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = BuildScripts Scripts MLPCostsWithRegionalization

EXTRA_DIST = MLPCostGraphs.tcl  bootstrap pdf4tcl05.zip TownData.csv

bin_SCRIPTS = MLPCostGraphs.kit
pkgdatadir = $(datadir)/$(PACKAGE)/Doc
noinst_DATA=html/index.html
pkgdata_DATA = UserMan.pdf
man1dir = $(mandir)/man1


MLPCostGraphsScripts = Scripts/DynamicHelp.tcl Scripts/IconsAndImages.tcl \
	     Scripts/mainwindow.tcl Scripts/snitbuttonbox.tcl \
	     Scripts/snitdialog.tcl Scripts/snitLFs.tcl \
	     Scripts/snitmainframe.tcl Scripts/snitscrollw.tcl \
	     Scripts/snitStdMenuBar.tcl Scripts/close.gif \
	     Scripts/DeepwoodsBanner.gif Scripts/new.gif \
	     Scripts/open.gif Scripts/print.gif Scripts/save.gif \
	     Scripts/gray50.xbm Scripts/info.xbm Scripts/questhead.xbm \
	     Scripts/openfold.gif Scripts/palette.gif Scripts/unknown.gif \
	     Scripts/gettext.tcl
	     
MLPCostGraphsData = TownData.csv

MLPCostGraphs.kit : MLPCostGraphs.tcl $(MLPCostGraphsScripts) pdf4tcl05.zip \
		$(MLPCostGraphsData)
	-rm -rf MLPCostGraphs.vfs MLPCostGraphs.kit
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/MLPCostGraphs.tcl
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap MLPCostGraphs.kit
	-rm -rf MLPCostGraphs.kit
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MLPCostGraphs \
		lib $(SNITLIB)
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MLPCostGraphs \
		lib $(CSVLIB)
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MLPCostGraphs \
		lib $(STRUCTLIB)
	$(UNZIP) -qq -d MLPCostGraphs.vfs/lib $(top_srcdir)/pdf4tcl05.zip
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit \
		-srcdir $(srcdir)\
		MLPCostGraphs lib/Common $(MLPCostGraphsScripts)
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit \
		MLPCostGraphs Common
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit \
		-srcdir $(srcdir) \
		MLPCostGraphs Data $(MLPCostGraphsData)		
	$(HOSTTCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap MLPCostGraphs.kit
	-rm -rf MLPCostGraphs.vfs

CLEANFILES  = MLPCostGraphs.kit
	                
html/index.html latex/refman.tex man/man1/MLPCostGraphs.1: MLPCostGraphs.tcl Doxyfile
	-rm -rf man
	$(DOXYGEN)
	
UserMan.pdf: latex/refman.tex
	$(MAKE) -C latex
	mv latex/refman.pdf UserMan.pdf
                
clean-local:
	-rm -rf man
	
install-data-hook: html/index.html man/man1
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/UserManHTML
	for p in html/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/UserManHTML/$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/UserManHTML/$$f"; \
	done
	test -z "$(man1dir)" || $(mkdir_p) "$(DESTDIR)$(man1dir)"
	@list=man/man1/* ; \
	for i in $$list; do \
	  file=$$i; \
	  ext=`echo $$i | sed -e 's/^.*\\.//'`; \
	  case "$$ext" in \
	    8*) ;; \
	    *) ext='8' ;; \
          esac; \
	  inst=`echo $$i | sed -e 's/\\.[0-9a-z]*$$//'`; \
	  inst=`echo $$inst | sed -e 's/^.*\///'`; \
	  inst=`echo $$inst | sed '$(transform)'`.$$ext; \
	  echo " $(INSTALL_DATA) '$$file' '$(DESTDIR)$(man1dir)/$$inst'"; \
	  $(INSTALL_DATA) "$$file" "$(DESTDIR)$(man1dir)/$$inst"; \
        done

uninstall-hook: 
	for p in $(DESTDIR)$(pkgdatadir)/UserManHTML/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/UserManHTML/$$f'"; \
	  rm -f "$(DESTDIR)$(pkgdatadir)/UserManHTML/$$f"; \
	done
	@list=man/man1/* ; \
	for i in $$list; do \
	  file=$$i; fi; \
	  ext=`echo $$i | sed -e 's/^.*\\.//'`; \
	  case "$$ext" in \
	    8*) ;; \
	    *) ext='8' ;; \
	  esac; \
	  inst=`echo $$i | sed -e 's/\\.[0-9a-z]*$$//'`; \
	  inst=`echo $$inst | sed -e 's/^.*\///'`; \
	  inst=`echo $$inst | sed '$(transform)'`.$$ext; \
	  echo " rm -f '$(DESTDIR)$(man1dir)/$$inst'"; \
	  rm -f "$(DESTDIR)$(man1dir)/$$inst"; \
	done
                                                                                                                       
