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
echoPROJECT = @echo -e "$(CYAN)**** $(PROJECT) ****$(NC) \n"


.PHONY:  all clean cleanall zip install uninstall
# Just create the PDF
all:
	$(MAKE) article
	$(MAKE) minimize
	$(MAKE) zip
	$(MAKE) count.colorpages
	$(echoPROJECT) "$(RED) * all files processed * $(NC)"

article:
	$(echoPROJECT) "$(RED) * making article * $(NC)"
	latexmk -lualatex -quiet -f -cd -view=pdf -output-directory=tmp/$(DATE) $(PROJECT).tex
	@cp tmp/$(DATE)/$(PROJECT).pdf .
	$(echoPROJECT) "$(RED) * article compiled * $(NC)"


# zip files up for sending etc.
zip: article
	$(echoPROJECT) "$(RED) * start zipping files * $(NC)"
	@-mkdir archive
	@rm -f archive/$(PROJECT)-$(DATE)*.zip
	@mkdir $(TDIR)
	@cp $(PROJECT).{bib,tex,pdf} README.md makefile $(TDIR)
	cd $(TEMP); \
	zip -Drq $(PWD)/archive/$(PROJECT)-$(VERS).zip $(PROJECT)
	$(echoPROJECT) "$(RED) * files zipped * $(NC)"


count.colorpages: article
	$(echoPROJECT) "$(RED) * counting colored pages * $(NC)"
	@echo -e "Pages with color:"
	@ gs -o - -sDEVICE=inkcov $(PROJECT).pdf | grep -v "^ 0.00000  0.00000  0.00000" | grep "^ " | wc -l
	@ gs \
  -o \
  - \
  -sDEVICE=inkcov \
  $(PROJECT).pdf \
  |tail -n +5 \
  |sed '/^Page*/N;s/\n//'\
  |sed -E '/Page [0-9]+ 0.00000 0.00000 0.00000 / d' \
  | tee  $(PROJECT).csv
	$(echoPROJECT) "$(RED) * colored pages counted * $(NC)"


minimize: article
	$(echoPROJECT) "$(RED) * minimizing article * $(NC)"
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
	$(echoPROJECT) "$(RED) * article minimized * $(NC)"
