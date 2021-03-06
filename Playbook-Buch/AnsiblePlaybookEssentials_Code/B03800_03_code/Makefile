#!/bin/bash
TARGETS = Readme
SOURCE = Readme.md

ZIEL = MySQL_und_Nginx

MYHEADER = ../../../../../Schule/pandoc-templates/myheader.tex

html:
	for i in $(TARGETS) ;	do \
		pandoc $$i.pmd -s -o $$i.pmd.html; \
	done

pdf_multi:
	pandoc --chapters --listings \
  -V geometry='paper=a4paper,left=3cm,right=2cm,top=3cm,bottom=3cm' \
  -H $(MYHEADER) \
  -V lang=de-De \
  -V fontsize=12pt \
	-V links-as-notes \
  -V papersize=oneside \
  -o out.tmp.tex $(SOURCE) ; \
	sed -e  's,\\begin{longtable}\[c\],\\begin{longtable}\[l\],' \
	    -e  's,\\medskip,,' \
	    -e  's,\@{},,g' \
	    -e  's,\\begin{minipage}\[b\],\\begin{minipage}\[t\],' \
	    -e  's,\\end{minipage},\\vspace{2mm}\\end{minipage},' \
	    -e  's,\\renewcommand{\\includegraphics},%,' \
	    -e  's,\\lstinline\#\(.*\)\#,\\lstinline|\1|,' \
  < out.tmp.tex > $(ZIEL).pmd.tex ; \
	pdflatex $(ZIEL).pmd.tex ; \
	rm $(ZIEL).pmd.tex ; \
	rm out.tmp.tex ; \
	rm $(ZIEL).pmd.log ; \
	rm $(ZIEL).pmd.aux ; \
	rm $(ZIEL).pmd.out ; \

pdf_single:
	for i in $(TARGETS) ;	do \
		pandoc --chapters --listings \
		  -V geometry='paper=a4paper,left=3cm,right=2cm,top=3cm,bottom=3cm' \
		  -H $(MYHEADER) \
		  -V lang=de-De \
		  -V fontsize=12pt \
			-V links-as-notes \
		  -V papersize=oneside \
		  -o $$i.tmp.tex $$i.pmd ; \
			sed -e  's,\\begin{longtable}\[c\],\\begin{longtable}\[l\],' \
			    -e  's,\\medskip,,' \
			    -e  's,\@{},,g' \
			    -e  's,\\begin{minipage}\[b\],\\begin{minipage}\[t\],' \
			    -e  's,\\end{minipage},\\vspace{2mm}\\end{minipage},' \
			    -e  's,\\renewcommand{\\includegraphics},%,' \
			    -e  's,\\lstinline\#\(.*\)\#,\\lstinline|\1|,' \
		  < $$i.tmp.tex > $$i.pmd.tex ; \
			pdflatex $$i.pmd.tex ; \
			rm $$i.pmd.tex ; \
			rm $$i.tmp.tex ; \
			rm $$i.pmd.log ; \
			rm $$i.pmd.aux ; \
			rm $$i.pmd.out ; \
		done

revealjs:
	for i in $(TARGETS) ;	do \
		pandoc $$i.pmd --standalone \
		 --slide-level=2 \
		 --from markdown \
		 -i -t revealjs \
		 -V theme=black \
		 --output $$i.pmd.revealjs.html \
		 -V revealjs-url="../reveal.js" ; \
	done

odt:
	for i in $(TARGETS) ;	do \
		pandoc $$i.pmd \
			--standalone \
			--output $$i.pmd.odt ; \
	done

all: odt revealjs html pdf_single pdf_multi

.PHONY: odt revealjs pdf_single pdf_multi html all
