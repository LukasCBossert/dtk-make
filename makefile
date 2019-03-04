PROJECT  = dtk-make-bossert
SHELL = bash
MAKE  = make
# zip
PWD   = $(shell pwd)
TEMP := $(shell mktemp -d -t tmp.XXXXXXXXXX)
TDIR  = $(TEMP)/$(PROJECT)
VERS  = $(shell /bin/date "+%Y-%m-%d---%H-%M-%S")
DATE  = $(shell /bin/date "+%Y-%m-%d")
# Colors
RED   = \033[0;31m
CYAN  = \033[0;36m
NC    = \033[0m
echoPROJECT = @echo -e "$(CYAN) <$(PROJECT)>$(RED)"

.PHONY: all article zip

# default
all:
	$(MAKE) article
	$(MAKE) minimize
	$(MAKE) zip
	$(MAKE) count.colorpages
	$(echoPROJECT) "* all files processed * $(NC)"

# compile article
article:
	$(echoPROJECT) "* making article * $(NC)"
	latexmk -lualatex -quiet -f -cd -view=pdf -output-directory=tmp $(PROJECT).tex
	@cp tmp/$(PROJECT).pdf .
	$(echoPROJECT) "* article compiled * $(NC)"

# zip files for sending etc.
zip: article
	$(echoPROJECT) "* start zipping files * $(NC)"
	@-mkdir archive
	@rm -f archive/$(PROJECT)-$(DATE)*.zip
	@mkdir $(TDIR)
	@cp $(PROJECT).{bib,tex,pdf} README.md makefile $(TDIR)
	cd $(TEMP); \
	zip -Drq $(PWD)/archive/$(PROJECT)-$(VERS).zip $(PROJECT)
	$(echoPROJECT) "* files zipped * $(NC)"

# count pages with colors > https://stackoverflow.com/a/28369599
count.colorpages: article
	$(echoPROJECT) "* counting colored pages * $(NC)"
	@ gs \
	-o - \
	-sDEVICE=inkcov \
	$(PROJECT).pdf \
	|tail -n +5 \
	|sed '/^Page*/N;s/\n//'\
	|sed -E '/Page [0-9]+ 0.00000 0.00000 0.00000 / d' \
	| tee  $(PROJECT).csv
	@echo -e "Total amount of pages with color: "
	@ gs -o - -sDEVICE=inkcov $(PROJECT).pdf | \
	 grep -v "^ 0.00000  0.00000  0.00000" | grep "^ " | wc -l
	$(echoPROJECT) "* colored pages counted * $(NC)"

# minimize PDF
minimize: article
	$(echoPROJECT) "* minimizing article * $(NC)"
	@-mkdir archive
	@rm -f archive/$(PROJECT)-$(DATE)*.pdf
	gs \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.4 \
  -dPDFSETTINGS=/printer \
  -dNOPAUSE \
  -dQUIET \
  -dBATCH \
  -sOutputFile=archive/$(PROJECT)-$(VERS).pdf \
  $(PROJECT).pdf
	$(echoPROJECT) "* article minimized * $(NC)"
