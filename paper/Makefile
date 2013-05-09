
STEM = dynexsyn

all:
	pdflatex ${STEM}.tex
	bibtex ${STEM}
	pdflatex ${STEM}.tex
	pdflatex ${STEM}.tex

clean:
	rm -rf *.{log,aux,blg,dvi,bbl}
