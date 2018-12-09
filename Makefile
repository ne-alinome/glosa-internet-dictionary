# Makefile of _Glosa Internet Directory_

# By Marcos Cruz (programandala.net)

# Last modified 201812091645
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
		-e 's/\("\|; \)\([^";]\{1,\}\)\s\[\([^";]\{1,\}\)\s]/\1\3 \2/g' \
		-e 's/\("\|; \)\([^";]\{1,\}\)\[\([^";]\{1,\}\)]/\1\3\2/g' \
		-e 's/\(\*\?\<1\?+\{0,2\}\*\?G\?X\?\)"/[\1]"/g' \
	> $@

# Description of the regular expressions done by `sed`:
#
# 1: Convert the line (with data separated by two spaces) into a CSV line.
# 2: Move the words in brackets before their main expression, and remove
#    the brackets.
# 3: Idem with the special cases, when there's no space in the brackets,
#    e.g. parens and hyphens.
# 4: Put the notation of word's origin in brackets.
# 5: Replace notation '(=' with "(→". Temporarily removed, until the
#    distiction between notations "=" and "prefer" is clear:
#		-e "s/(=/(→/g" \

# XXX REMARK -- There's a typo in GID: the description of 'akademi' should be
# '1*' instead of '*1'.
#
# The 4th regular expression:
#
#		-e 's/\<\(1\?+\{0,2\}\*\?G\?X\?\)"/[\1]"/g' \
#
# has been temporarily modified in order to catch that case:
#
#		-e 's/\(\*\?\<1\?+\{0,2\}\*\?G\?X\?\)"/[\1]"/g' \

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
#
# 2018-12-09: Finish the regular expressions that rearrange the parts in
# brackets. Put the notes of word origins into brackets.
