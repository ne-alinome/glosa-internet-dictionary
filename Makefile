# Makefile of _Glosa Internet Directory_

# By Marcos Cruz (programandala.net)

# Last modified 201812090006
# See change log at the end of the file

# ==============================================================
# Requirements

# - make
# - asciidoctor
# - pandoc

# ==============================================================
# Config

VPATH=./src:./target:./original

book=glosa_internet_dictionary

# ==============================================================
# Interface

.PHONY: all
all: epub html

.PHONY: clean
clean:
	rm -f target/* tmp/*

.PHONY: epub
epub: \
	target/$(book).adoc.xml.pandoc.epub

.PHONY: html
html: \
	target/$(book).adoc.html \
	target/$(book).adoc.plain.html \
	target/$(book).adoc.xml.pandoc.html

# ==============================================================
# Convert to Asciidoctor

# ----------------------------------------------

# The original text files are converted to CSV (Comma Separated Values) files.
# The '%' comments are removed and the encoding is changed to UTF-8 (required
# by all target formats). Some text manipulations are required as well.

tmp/%.csv: original/%.txt.gz
	zcat $< \
	| iconv --from-code latin1 --to-code utf-8 \
	| grep --invert-match "^%" \
	| tr '[{}]' '[()]' \
	| sed \
		-e "s/\(.*\S\{1,\}\)   *\(.\+\S\) *$$/\"\1\",\"\2\"/" \
		-e "s/\(.\)\([^\";]\{1,\}\)\( *\)\[\(.\{1,\}\)]/\1\4\3\2/g" \
	> $@

# XXX FIXME -- The moving of the brackets (the second expression of the `sed`
# command) does not work fine yet:

# This moves the contents of the brackets to the start of the line:
#		-e "s/\([\";]\)\(.\+\)\( *\)\[\(.\{1,\}\)]/\1\4\3\2/" \
# This fails only in some cases:
#		-e "s/\(.\)\([^\";]\{1,\}\)\( *\)\[\(.\{1,\}\)]/\1\4\3\2/g" \

# ----------------------------------------------

# The Asciidoctor source is simply copied into the target directory.  Its
# `include::` macros will integrate the CSV files during the translation into
# DocBook or HTML:

%.adoc: tmp/engl.csv tmp/glen.csv
	cp src/glosa_internet_dictionary.adoc $@

# ==============================================================
# Convert to DocBook

%.adoc.xml: %.adoc
	adoc --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert to EPUB

# NB: Pandoc does not allow alternative templates. The default templates must
# be modified or redirected instead. They are the following:
# 
# /usr/share/pandoc-1.9.4.2/templates/epub-coverimage.html
# /usr/share/pandoc-1.9.4.2/templates/epub-page.html
# /usr/share/pandoc-1.9.4.2/templates/epub-titlepage.html

%.adoc.xml.pandoc.epub: %.adoc.xml
	pandoc \
		--from=docbook \
		--to=epub \
		--output=$@ \
		$<

# ==============================================================
# Convert to HTML

%.adoc.plain.html: %.adoc
	adoc \
		--attribute="stylesheet=none" \
		--quiet \
		--out-file=$@ \
		$<

%.adoc.html: %.adoc
	adoc --out-file=$@ $<

%.adoc.xml.pandoc.html: %.adoc.xml
	pandoc \
		--from=docbook \
		--to=html \
		--standalone \
		--output=$@ \
		$<

# ==============================================================
# Change log

# 2018-12-06: Start. Create an Asciidoctor document from the original data
# files.
#
# 2018-12-08: Rewrite.  Use the original data files to build the tables of the
# Asciidoctor source. This makes it possible to update the e-book whenever the
# original data is updated in glosa.org.
