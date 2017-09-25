##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon Sep 25 10:26:26 2017
#  Last Modified : <170925.1208>
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


SUFFIXES        = .tex .sty

MLPCOSTSWITHREGIONALIZATION = MLPCostsWithRegionalization
MLPCOSTSWITHREGIONALIZATION_TEXS = $(MLPCOSTSWITHREGIONALIZATION).tex
MLPCOSTSWITHREGIONALIZATION_FIGS = WENDELL-PerMile.pdf WENDELL-PerNetwork.pdf \
	SHUTESBURY-PerMile.pdf     SHUTESBURY-PerNetwork.pdf \
	NEW_SALEM-SHUTESBURY-WENDELL-PerMile.pdf \
	NEW_SALEM-SHUTESBURY-WENDELL-PerNetwork.pdf \
	BECKET-GOSHEN-HEATH-NEW_ASHFORD-NEW_SALEM-PLAINFIELD-ROWE-SHUTESBURY-WASHINGTON-WENDELL-WINDSOR-PerMile.pdf \
	BECKET-GOSHEN-HEATH-NEW_ASHFORD-NEW_SALEM-PLAINFIELD-ROWE-SHUTESBURY-WASHINGTON-WENDELL-WINDSOR-PerNetwork.pdf
MLPCOSTSWITHREGIONALIZATION_PDF = $(MLPCOSTSWITHREGIONALIZATION).pdf

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

CLEANFILES = $(MLPCOSTSWITHREGIONALIZATION).pdf *.aux *.bbl *.blg *.idx *.ilg \
	*.ind *.lof *.lot *.lol *.toc *.log
	
pkgdata_DATA = $(MLPCOSTSWITHREGIONALIZATION_PDF)

BIBLIO = MLPCostsWithRegionalization.bib

EXTRA_DIST = $(MLPCOSTSWITHREGIONALIZATION_TEXS) $(BIBLIO) \
		$(MLPCOSTSWITHREGIONALIZATION_FIGS) 
		

$(MLPCOSTSWITHREGIONALIZATION_PDF) : $(MLPCOSTSWITHREGIONALIZATION_TEXS) \
		$(BIBLIO) $(MLPCOSTSWITHREGIONALIZATION_FIGS)
		
	-ln -s $(srcdir)/$(BIBLIO) ./
	for f in $(MLPCOSTSWITHREGIONALIZATION_TEXS) \
		 $(MLPCOSTSWITHREGIONALIZATION_FIGS); do \
	  if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	$(PDFLATEX) $(MLPCOSTSWITHREGIONALIZATION).tex
	-$(BIBTEX) $(MLPCOSTSWITHREGIONALIZATION)
	$(PDFLATEX) $(MLPCOSTSWITHREGIONALIZATION).tex
	-$(MAKEINDEX) $(MLPCOSTSWITHREGIONALIZATION).idx
	$(PDFLATEX) $(MLPCOSTSWITHREGIONALIZATION).tex
	$(PDFLATEX) $(MLPCOSTSWITHREGIONALIZATION).tex
	
