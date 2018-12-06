# Makefile of _Glosa Internet Directory_

# By Marcos Cruz (programandala.net)

# Last modified 201812061355
# See change log at the end of the file

# ==============================================================
# Requirements

# - make
# - asciidoctor
# - pandoc

# ==============================================================
# Config

VPATH=./src:./target

book=glosa_internet_dictionary

# ==============================================================
# Interface

.PHONY: all
all: epub html

.PHONY: clean
clean: rm -f target/*

.PHONY: epub
epub: \
	target/$(book).adoc.xml.pandoc.epub

.PHONY: html
html: \
	target/$(book).adoc.html \
	target/$(book).adoc.plain.html \
	target/$(book).adoc.xml.pandoc.html

# ==============================================================
# Convert to DocBook

target/$(book).adoc.xml: $(book).adoc
	adoc --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert to EPUB

# NB: Pandoc does not allow alternative templates. The default templates must
# be modified or redirected instead. They are the following:
# 
# /usr/share/pandoc-1.9.4.2/templates/epub-coverimage.html
# /usr/share/pandoc-1.9.4.2/templates/epub-page.html
# /usr/share/pandoc-1.9.4.2/templates/epub-titlepage.html

target/$(book).adoc.xml.pandoc.epub: target/$(book).adoc.xml
	pandoc \
		--from=docbook \
		--to=epub \
		--output=$@ \
		$<

# ==============================================================
# Convert to HTML

target/$(book).adoc.plain.html: $(book).adoc
	adoc \
		--attribute="stylesheet=none" \
		--quiet \
		--out-file=$@ \
		$<

target/$(book).adoc.html: $(book).adoc
	adoc --out-file=$@ $<

target/$(book).adoc.xml.pandoc.html: target/$(book).adoc.xml
	pandoc \
		--from=docbook \
		--to=html \
		--output=$@ \
		$<

# ==============================================================
# Change log

# 2018-12-06: Start.
