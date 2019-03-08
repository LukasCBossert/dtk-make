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
	latexmk \
	 -lualatex \
	 -quiet \
	 -view=pdf \
	 -output-directory=tmp \
	$(PROJECT).tex
	@cp tmp/$(PROJECT).pdf .
	$(echoPROJECT) "* article compiled * $(NC)"

# zip files for sending etc.
zip: article
	$(echoPROJECT) "* start zipping files * $(NC)"
	@-mkdir archive
	@rm -f archive/$(PROJECT)-$(DATE)*.zip
	@mkdir $(TDIR)
	@cp $(PROJECT).{bib,tex,pdf} README.md makefile $(TDIR)
	@cd $(TEMP); \
	 zip -Drq $(PWD)/archive/$(PROJECT)-$(VERS).zip $(PROJECT)
	$(echoPROJECT) "* files zipped * $(NC)"

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

# count pages with colors
# > https://stackoverflow.com/a/28369599
# > https://stackoverflow.com/q/54991314
count.colorpages:
	$(echoPROJECT) "* listing and counting colored pages * $(NC)"
	@echo "Meta information about colors in $(PROJECT): "
	@gs -o - -sDEVICE=inkcov $(PROJECT).pdf \
	 | tail -n +5 \
	 | sed '/^Page*/N;s/\n//' \
	 | tee $(PROJECT).csv
	@echo -n "List of pages with colors: "
	@cat $(PROJECT).csv \
	 | awk '$$3!="0.00000" ||  $$4!="0.00000" || $$5!="0.00000"{if(length(colored))colored=colored","$$2;else colored=$$2} END{print colored}' \
	 | tee  -a $(PROJECT).csv
	@echo -n "Total amount of pages with color: "
	@gs -o - -sDEVICE=inkcov $(PROJECT).pdf \
	 | grep -v "^ 0.00000  0.00000  0.00000" \
	 | grep "^ " \
	 | wc -l \
	 | sed 's/[[:space:]]//g' \
	 | tee  -a $(PROJECT).csv
	$(echoPROJECT) "* colored pages listed and counted * $(NC)"
