#!/bin/bash
TARGETS = Umgebungen_Verwalten
SOURCE = Umgebungen_Verwalten.md

ZIEL = MySQL_und_Nginx

MYHEADER = ../../../../../Schule/pandoc-templates/myheader.tex

html:
	for i in $(TARGETS) ;	do \
		pandoc $$i.md -s -o $$i.md.html; \
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
  < out.tmp.tex > $(ZIEL).md.tex ; \
	pdflatex $(ZIEL).md.tex ; \
	rm $(ZIEL).md.tex ; \
	rm out.tmp.tex ; \
	rm $(ZIEL).md.log ; \
	rm $(ZIEL).md.aux ; \
	rm $(ZIEL).md.out ; \

pdf_single:
	for i in $(TARGETS) ;	do \
		pandoc --chapters --listings \
		  -V geometry='paper=a4paper,left=3cm,right=2cm,top=3cm,bottom=3cm' \
		  -H $(MYHEADER) \
		  -V lang=de-De \
		  -V fontsize=12pt \
			-V links-as-notes \
		  -V papersize=oneside \
		  -o $$i.tmp.tex $$i.md ; \
			sed -e  's,\\begin{longtable}\[c\],\\begin{longtable}\[l\],' \
			    -e  's,\\medskip,,' \
			    -e  's,\@{},,g' \
			    -e  's,\\begin{minipage}\[b\],\\begin{minipage}\[t\],' \
			    -e  's,\\end{minipage},\\vspace{2mm}\\end{minipage},' \
			    -e  's,\\renewcommand{\\includegraphics},%,' \
			    -e  's,\\lstinline\#\(.*\)\#,\\lstinline|\1|,' \
		  < $$i.tmp.tex > $$i.md.tex ; \
			pdflatex $$i.md.tex ; \
			rm $$i.md.tex ; \
			rm $$i.tmp.tex ; \
			rm $$i.md.log ; \
			rm $$i.md.aux ; \
			rm $$i.md.out ; \
		done

revealjs:
	for i in $(TARGETS) ;	do \
		pandoc $$i.md --standalone \
		 --slide-level=2 \
		 --from markdown \
		 -i -t revealjs \
		 -V theme=black \
		 --output $$i.md.revealjs.html \
		 -V revealjs-url="../reveal.js" ; \
	done

odt:
	for i in $(TARGETS) ;	do \
		pandoc $$i.md \
			--standalone \
			--output $$i.md.odt ; \
	done

all: odt revealjs html pdf_single pdf_multi

diff:
	diff -uNr -X ./diffignore ../B03800_08_code/ ./ > Umgebungen_verwalten.diff ;

.PHONY: odt revealjs pdf_single pdf_multi html all
