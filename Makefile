# Makefile of _Glosa Internet Directory_

# By Marcos Cruz (programandala.net)

# Last modified 201812092015
# See change log at the end of the file

# ==============================================================
# Requirements

# - make
# - asciidoctor
# - grep
# - pandoc
# - tr
# - sed
# - zcat

# ==============================================================
# Config

VPATH=./src:./target:./original

# ----------------------------------------------

book=glosa_internet_dictionary

# ----------------------------------------------

# Set the mark which will be added at the start of every entry, in order to
# facilitate searches in e-books, where regexp are not available. I.e.
# searching the book for "word" will find the string "word" in any position of
# the text, including as part of longer words, but searching for ">word" will
# find only the dictionary entry.

bullet=>

# ==============================================================
# Interface

.PHONY: all
all: paragraphs_epub html

.PHONY: clean
clean:
	rm -f target/* tmp/*

.PHONY: data
data: csv lists paragraphs linebreaks

.PHONY: csv
csv: tmp/engl.csv tmp/glen.csv

.PHONY: lists
lists: tmp/engl.list.adoc tmp/glen.list.adoc

.PHONY: paragraphs
paragraphs: tmp/engl.paragraph.adoc tmp/glen.paragraph.adoc

.PHONY: linebreaks
linebreaks: tmp/engl.linebreak.adoc tmp/glen.linebreak.adoc

.PHONY: epub
epub: paragraphs_epub lists_epub tables_epub

.PHONY: paragraphs_epub
paragraphs_epub: target/$(book).paragraphs.adoc.xml.pandoc.epub

.PHONY: lists_epub
lists_epub: target/$(book).lists.adoc.xml.pandoc.epub

.PHONY: tables_epub
tables_epub: target/$(book).tables.adoc.xml.pandoc.epub

# XXX TODO --
#	target/$(book).linebreaks.adoc.xml.pandoc.epub

.PHONY: html
html: \
	target/$(book).paragraphs.adoc.html \
	target/$(book).paragraphs.adoc.plain.html \
	target/$(book).paragraphs.adoc.xml.pandoc.html \
	target/$(book).lists.adoc.html \
	target/$(book).lists.adoc.plain.html \
	target/$(book).lists.adoc.xml.pandoc.html \
	target/$(book).tables.adoc.html \
	target/$(book).tables.adoc.plain.html \
	target/$(book).tables.adoc.xml.pandoc.html

# XXX TODO --
#	target/$(book).linebreaks.adoc.html \
#	target/$(book).linebreaks.adoc.plain.html \
#	target/$(book).linebreaks.adoc.xml.pandoc.html \

# ==============================================================
# Convert the original data files

# ----------------------------------------------
# Basic tidy

# The encoding of the original data files is changed to UTF-8 (required by all
# target formats), and the comment lines are removed.

tmp/%.txt: original/%.txt.gz Makefile
	zcat $< \
	| iconv --from-code latin1 --to-code utf-8 \
	| grep --invert-match "^%" \
	| tr '[{}]' '[()]' > $@

# ----------------------------------------------
# Convert into CSV (Comma Separated Values)

%.csv: %.txt
	cat $< \
	| sed \
		-e "s/\(.*\S\{1,\}\)   *\(.\+\S\) *$$/\"$(bullet)\1\",\"\2\"/" \
		-e 's/\("\|; \)\([^";]\{1,\}\)\s\[\([^";]\{1,\}\)\s]/\1\3 \2/g' \
		-e 's/\("\|; \)\([^";]\{1,\}\)\[\([^";]\{1,\}\)]/\1\3\2/g' \
		-e 's/\(\*\?\<1\?+\{0,2\}\*\?G\?X\?\)\([";]\)/[\1]\2/g' \
		-e 's/\([";]\)\([^";]\+\); \2\([";]\)/\1\2\3/' \
	> $@

# Description of the regular expressions done by `sed`:
#
# 1: Convert the line (with data separated by two spaces) into a CSV line.
# 2: Move the words in brackets before their main expression, and remove
#    the brackets.
# 3: Idem with the special cases, when there's no space in the brackets,
#    e.g. parens and hyphens.
# 4: Put the notation of word's origin in brackets.
# 5: Remove repeated meanings caused by variants in brackets.
# 6: Replace notation '(=' with "(→". Temporarily removed, until the
#    distiction between notations "=" and "prefer" is clear:
#		-e "s/(=/(→/g" \

# XXX REMARK -- There's a typo in GID: the description of 'akademi' should be
# '1*' instead of '*1'.
#
# The 4th regular expression:
#
#		-e 's/\<\(1\?+\{0,2\}\*\?G\?X\?\)[";]/[\1]\2"/g' \
#
# has been temporarily modified in order to catch that case:
#
#		-e 's/\(\*\?\<1\?+\{0,2\}\*\?G\?X\?\)[";]/[\1]\2"/g' \

# XXX REMARK -- This CSV line
#
# 	"aito G","burnt brown; brown [burnt ]"
#
# becomes this one after moving the parts in brackets:
#
# 	"aito [G]","burnt brown; burnt brown"
#
# It's goal is to show "burnt brown" under "brown".
# There are other similar cases. 
# The repetions must be removed.

# XXX OLD -- Tries:
#
# This moves the contents of the brackets to the start of the line:
#		-e "s/\([\";]\)\(.\+\)\( *\)\[\(.\{1,\}\)]/\1\4\3\2/" \
#
# This fails only in some cases:
#
#		-e "s/\(.\)\([^\";]\{1,\}\)\( *\)\[\(.\{1,\}\)]/\1\4\3\2/g" \
#
# This fails only in some cases, no difference:
#
#		-e "s/\(.\)\([^\";]\{1,\}\)\( *\)\[\(.\{1,\}\)]/\1\4\2/g" \
#
# This do nothing:
#
#		-e "s/\(\(\"\|; \)\{1,\}\)\s\[\(.\{1,\}\)\s]/\2\1/g" \
#
# This remove the brackets:
#
#		-e "s/\(\"\|; \)\(.\+\)\s\[\(.\{1,\}\)\s]/\1\3\2/g" \
#
# This converts brackets separated with spaces, but fails
# when there are two cases on the same line. Besides, it ignores
# other brackets, e.g. with hyphens:
#
#		-e 's/\("\|; \)\([^";,]\{1,\}\)\s\[\(.\{1,\}\)\s]/\1\3 \2/g' \
#
# This works fine with several cases on the same line:
#
#		-e 's/\("\|; \)\([^";,]\{1,\}\)\s\[\([^";,]\{1,\}\)\s]/\1\3 \2/g' \
#
# This additional command replaces the spaceless brackets, e.g. hyphens,
# but misses the special case of 'komo' (because it has a comma in the brackets):
#
#		-e 's/\("\|; \)\([^";,]\{1,\}\)\[\([^";,]\{1,\}\)]/\1\3\2/g' \
#
# This pair of commands replaces all brackets:
#
#		-e 's/\("\|; \)\([^";]\{1,\}\)\s\[\([^";]\{1,\}\)\s]/\1\3 \2/g' \
#
#		-e 's/\("\|; \)\([^";]\{1,\}\)\[\([^";]\{1,\}\)]/\1\3\2/g' \
#
# This combined form ignores the spaceless brackets:
#
#		-e 's/\("\|; \)\([^";]\{1,\}\)\(\s\)\?\[\([^";]\{1,\}\)\3]/\1\4\3\2/g' \

# ----------------------------------------------
# Convert into Asciidoctor unordered lists

%.list.adoc: %.txt
	cat $< \
	| sed \
		-e 's/\(.*\S\{1,\}\)   *\(.\+\S\) *$$/\* $(bullet)|\1\|: |\2|/' \
		-e 's/\(|\|; \)\([^|;]\{1,\}\)\s\[\([^|;]\{1,\}\)\s]/\1\3 \2/g' \
		-e 's/\(|\|; \)\([^|;]\{1,\}\)\[\([^|;]\{1,\}\)]/\1\3\2/g' \
		-e 's/\(\*\?\<1\?+\{0,2\}\*\?G\?X\?\)\([|;]\)/[\1]\2/g' \
		-e 's/\([|;]\)\([^|;]\+\); \2\([|;]\)/\1\2\3/' \
		-e 's/|//g' \
	> $@

# ----------------------------------------------
# Convert into Asciidoctor paragraph with line breaks

# XXX FIXME -- This does not work. See details in the TO-DO file.

%.linebreak.adoc: %.txt
	cat $< \
	| sed \
		-e 's/\(.*\S\{1,\}\)   *\(.\+\S\) *$$/$(bullet)|\1\|: |\2| +/' \
		-e 's/\(|\|; \)\([^|;]\{1,\}\)\s\[\([^|;]\{1,\}\)\s]/\1\3 \2/g' \
		-e 's/\(|\|; \)\([^|;]\{1,\}\)\[\([^|;]\{1,\}\)]/\1\3\2/g' \
		-e 's/\(\*\?\<1\?+\{0,2\}\*\?G\?X\?\)\([|;]\)/[\1]\2/g' \
		-e 's/\([|;]\)\([^|;]\+\); \2\([|;]\)/\1\2\3/' \
		-e 's/|//g' \
	> $@

# ----------------------------------------------
# Convert into Asciidoctor paragraphs

%.paragraph.adoc: %.txt
	cat $< \
	| sed \
		-e 's/\(.*\S\{1,\}\)   *\(.\+\S\) *$$/$(bullet)|\1\|: |\2|\n/' \
		-e 's/\(|\|; \)\([^|;]\{1,\}\)\s\[\([^|;]\{1,\}\)\s]/\1\3 \2/g' \
		-e 's/\(|\|; \)\([^|;]\{1,\}\)\[\([^|;]\{1,\}\)]/\1\3\2/g' \
		-e 's/\(\*\?\<1\?+\{0,2\}\*\?G\?X\?\)\([|;]\)/[\1]\2/g' \
		-e 's/\([|;]\)\([^|;]\+\); \2\([|;]\)/\1\2\3/' \
		-e 's/|//g' \
	> $@

# ==============================================================
# Convert to Asciidoctor

# The Asciidoctor source is simply copied into the target directory.  Its
# `include::` macros will integrate the CSV files during the translation into
# DocBook or HTML:

target/$(book).tables.adoc: \
		tmp/engl.csv \
		tmp/glen.csv \
		src/$(book).common.adoc
	cp src/glosa_internet_dictionary.tables.adoc $@

target/$(book).lists.adoc: \
		tmp/engl.list.adoc \
		tmp/glen.list.adoc \
		src/$(book).common.adoc
	cp src/glosa_internet_dictionary.lists.adoc $@

target/$(book).paragraphs.adoc: \
		tmp/engl.paragraph.adoc \
		tmp/glen.paragraph.adoc \
		src/$(book).common.adoc
	cp src/glosa_internet_dictionary.paragraphs.adoc $@

target/$(book).linebreaks.adoc: \
		tmp/engl.linebreak.adoc \
		tmp/glen.linebreak.adoc \
		src/$(book).common.adoc
	cp src/glosa_internet_dictionary.linebreaks.adoc $@

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
#
# 2018-12-09:
#
# Finish the regular expressions that rearrange the parts in brackets.
#
# Put the notes of word origins into brackets.
#
# Make a rule to build both CSV files, using Makefile as prerrequisite; this
# makes testing easier.
#
# Remove duplicated meanings caused by variants in brackets.
#
# Mark entries with a hardcoded bullet, in order to make searches easier.
#
# Build a variant target, using lists, which the e-reader renders much faster
# than tables.  Build also a target using paragraphs, which is even a bit
# faster.
