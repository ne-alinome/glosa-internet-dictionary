# Makefile of _Glosa Internet Directory_

# By Marcos Cruz (programandala.net)

# Last modified 201812242248
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

# Base filenames

complete_version=glosa_dictionary
english_glosa_version=english-glosa_dictionary
glosa_english_version=glosa-english_dictionary

# ----------------------------------------------

# A temporary field separator.  Any character not used in the original data
# file is valid.
#
# Note: This character must be different from the `bullet` variable.

separator=|

# ----------------------------------------------

# A mark that will be added at the start of every entry, in order to facilitate
# searches in e-books, where regular expressions are not available. I.e.
# searching the book for "word" will find the string "word" in any position of
# the text, including as part of longer words, but searching for ">word" will
# find only the dictionary entry.
#
# Note: This character must be different from the `separator` variable.

bullet=>

# ==============================================================
# Interface

.PHONY: all
all: epub

.PHONY: clean
clean:
	rm -f target/* tmp/*

.PHONY: data
data: csv list paragraph linebreak

.PHONY: csv
csv: tmp/engl.csv tmp/glen.csv

.PHONY: jargon
jargon: tmp/engl.jargon.txt tmp/glen.jargon.txt

.PHONY: dict
dict: \
	target/$(english_glosa_version).dict.dz \
	target/$(glosa_english_version).dict.dz

.PHONY: list
list: tmp/engl.list.adoc tmp/glen.list.adoc

.PHONY: paragraph
paragraph: tmp/engl.paragraph.adoc tmp/glen.paragraph.adoc

.PHONY: linebreak
linebreak: tmp/engl.linebreak.adoc tmp/glen.linebreak.adoc

.PHONY: epub
epub: epub_with_paragraphs

.PHONY: epub_with_paragraphs
epub_with_paragraphs: \
	target/$(complete_version).paragraph.adoc.xml.pandoc.epub \
	target/$(english_glosa_version).paragraph.adoc.xml.pandoc.epub \
	target/$(glosa_english_version).paragraph.adoc.xml.pandoc.epub

.PHONY: epub_with_lists
epub_with_lists: \
	target/$(complete_version).list.adoc.xml.pandoc.epub \
	target/$(english_glosa_version).list.adoc.xml.pandoc.epub \
	target/$(glosa_english_version).list.adoc.xml.pandoc.epub

.PHONY: epub_with_tables
epub_with_tables: \
	target/$(complete_version).table.adoc.xml.pandoc.epub \
	target/$(english_glosa_version).table.adoc.xml.pandoc.epub \
	target/$(glosa_english_version).table.adoc.xml.pandoc.epub

# XXX TODO --
#	target/$(complete_version).linebreak.adoc.xml.pandoc.epub

.PHONY: html
html: html_with_lists

.PHONY: html_with_paragraphs
html_with_paragraphs: \
	target/$(complete_version).paragraph.adoc.html \
	target/$(complete_version).paragraph.adoc.plain.html \
	target/$(complete_version).paragraph.adoc.xml.pandoc.html \
	target/$(english_glosa_version).paragraph.adoc.html \
	target/$(english_glosa_version).paragraph.adoc.plain.html \
	target/$(english_glosa_version).paragraph.adoc.xml.pandoc.html \
	target/$(glosa_english_version).paragraph.adoc.html \
	target/$(glosa_english_version).paragraph.adoc.plain.html \
	target/$(glosa_english_version).paragraph.adoc.xml.pandoc.html

.PHONY: html_with_lists
html_with_lists: \
	target/$(complete_version).list.adoc.html \
	target/$(complete_version).list.adoc.plain.html \
	target/$(complete_version).list.adoc.xml.pandoc.html \
	target/$(english_glosa_version).list.adoc.html \
	target/$(english_glosa_version).list.adoc.plain.html \
	target/$(english_glosa_version).list.adoc.xml.pandoc.html \
	target/$(glosa_english_version).list.adoc.html \
	target/$(glosa_english_version).list.adoc.plain.html \
	target/$(glosa_english_version).list.adoc.xml.pandoc.html

.PHONY: html_with_tables
html_with_tables: \
	target/$(complete_version).table.adoc.html \
	target/$(complete_version).table.adoc.plain.html \
	target/$(complete_version).table.adoc.xml.pandoc.html \
	target/$(english_glosa_version).table.adoc.html \
	target/$(english_glosa_version).table.adoc.plain.html \
	target/$(english_glosa_version).table.adoc.xml.pandoc.html \
	target/$(glosa_english_version).table.adoc.html \
	target/$(glosa_english_version).table.adoc.plain.html \
	target/$(glosa_english_version).table.adoc.xml.pandoc.html

# XXX TODO --
#.PHONY: html_with_linebreaks
#html_with_linebreaks: \
#	target/$(complete_version).linebreak.adoc.html \
#	target/$(complete_version).linebreak.adoc.plain.html \
#	target/$(complete_version).linebreak.adoc.xml.pandoc.html \
#	target/$(english_glosa_version).linebreak.adoc.html \
#	target/$(english_glosa_version).linebreak.adoc.plain.html \
#	target/$(english_glosa_version).linebreak.adoc.xml.pandoc.html \
#	target/$(glosa_english_version).linebreak.adoc.html \
#	target/$(glosa_english_version).linebreak.adoc.plain.html \
#	target/$(glosa_english_version).linebreak.adoc.xml.pandoc.html

# ==============================================================
# Convert the original data files

# NOTE: The `.SECONDARY` special target prevents intermediate files from being
# removed at the end.  See section "10.4 Chains of Implicit Rules" of the GNU
# make manual.

# ----------------------------------------------
# Basic tidy

# - Change the encoding of the original data files to UTF-8 (as required by all
#   target formats).
# - Remove comment lines.
# - Remove empty lines, just in case.
# - Fix typo in the description notation of 'akademi': "*1" -> "1*".
# - Add a field separator at the start of the lines.
# - Add a field separator between the fields, preceding a semicolon and a space,
#   in order to mark the start of a definition and make later expressions simpler.
# - Replace curly brackets with parens.

.SECONDARY: tmp/engl.tidy_0_basic.txt tmp/glen.tidy_0_basic.txt

tmp/%.tidy_0_basic.txt: original/%.txt.gz Makefile
	zcat $< \
	| iconv --from-code latin1 --to-code utf-8 \
	| grep --invert-match "^%" \
	| grep --invert-match "^$$" \
	| sed \
		-e '/akademi/s/\*1+/1+\*/' \
		-e 's/ \+$$//' \
		-e 's/^/$(separator)/' \
		-e 's/  \+/$(separator)/' \
		-e 's/\($(separator)\|; \)\([^$(separator);]\+\)\[\([^$(separator);]\+\)]/\1\3\2/g' \
		-e 's/ $(separator)/$(separator)/g' \
		-e 's/ \(1+\{0,2\}\*\?X\?G\?\)/ [\1]/g' \
		-e 's/\<\(X\)\($$\|;\)/[\1]\2/g' \
		-e 's/\<\(G\)\($$\|;\)/[\1]\2/g' \
		-e 's/\(+\{1,2\}\)$$/[\1]/g' \
		-e 's/\([$(separator);]\)\([^$(separator);]\+\); \2\([$(separator);]\)/\1\2\3/' \
	| tr '[{}]' '[()]' > $@

# Description of the `sed` commands:
#
# 1: Fix typo in the description of entry 'akademy'.
#
# 2: Remove trailing spaces.
#
# 3: Add the separator at the start of the lines.
#
# 4: Use the separator to separate the fields, instead two or more spaces.
#
# 5: Move the second part of the compound expressions, which are in brackets,
# before their main entry, and remove the brackets.
#
# 6: Remove spaces caused by command #5 in some cases.
#
# 7: Put the notes about the entry into brackets.
#
# 8: Put the notes 'X' alone into brackets (not catched by the command #7).
#
# 9: Put the notes 'G' alone into brackets (not catched by the command #7).
#
# 10: Put the notes '+/++' alone into brackets (not catched by the command #7).
#
# 11: Remove duplicated expressions caused by command #5.

# ----------------------------------------------
# Additional tidy for dict

# Move the notes about the word, if any, to the description field.

.SECONDARY: tmp/engl.tidy_1_dict.txt tmp/glen.tidy_1_dict.txt

%.tidy_1_dict.txt: %.tidy_0_basic.txt Makefile
	cat $< \
	| sed \
		-e 's/ \(\[.\+\]\)$(separator)/$(separator)\1 /' \
	> $@

# ----------------------------------------------
# Convert into CSV (Comma Separated Values)

# CSV format (with bullet '>' prefix added):
#
# -------------------
# ">word1","definition 1"
# ">word2","definition 2"
# -------------------

%.csv: %.tidy_0_basic.txt
	cat $< \
	| sed \
		-e 's/^|\([^|]\+\)|\(.\)$$/"\1","\2"/' \
		-e 's/"/"$(bullet)/' \
	> $@

# Description of the `sed` commands:
#
# 1: Convert the lines to CSV.
#
# 2: Add the bullet before the term.

# ----------------------------------------------
# Convert into Jargon format

# Jargon format:
#
# -------------------
# :word1:definition 1
# :word2:definition 2
# -------------------

%.jargon.txt: %.tidy_1_dict.txt
	cat $< \
	| sed \
		-e 's/|/:/g' \
	> $@

# ----------------------------------------------
# Convert into Asciidoctor unordered lists

%.list.adoc: %.tidy_0_basic.txt
	cat $< \
	| sed \
		-e 's/^|/- $(bullet)/' \
		-e 's/|/: /' \
	> $@

# ----------------------------------------------
# Convert into Asciidoctor paragraph with line breaks

# XXX FIXME -- This does not work. See details in the TO-DO file.

%.linebreak.adoc: %.tidy_0_basic.txt
	cat $< \
	| sed \
		-e 's/^|/$(bullet)/' \
		-e 's/|/: /' \
		-e 's/$$/ +/' \
	> $@

# ----------------------------------------------
# Convert into Asciidoctor paragraph

%.paragraph.adoc: %.tidy_0_basic.txt
	cat $< \
	| sed \
		-e 's/^|/$(bullet)/' \
		-e 's/|/: /' \
		-e 's/$$/\n/' \
	> $@

# ==============================================================
# Convert to dict and install it

target/$(english_glosa_version).dict: tmp/engl.jargon.txt
	dictfmt \
		--utf8 \
		--allchars \
		-u "http://glosa.org" \
		-s "Glosa Internet Dictionary (English-Glosa)" \
		-j $(basename $@) \
		< $<

target/$(glosa_english_version).dict: tmp/glen.jargon.txt
	dictfmt \
		--utf8 \
		--allchars \
		-u "http://glosa.org" \
		-s "Glosa Internet Dictionary (Glosa-English)" \
		-j $(basename $@) \
		< $<

%.dict.dz: %.dict
	dictzip --force $<

.PHONY: install
install: \
	target/$(english_glosa_version).dict.dz \
	target/$(glosa_english_version).dict.dz
	cp --force \
		$^ \
		$(addsuffix .index, $(basename $(basename $^))) \
		/usr/share/dictd/
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

# ==============================================================
# Convert to Asciidoctor

#  ---------------------------------------------
#  Complete versions

target/$(complete_version).table.adoc: \
		tmp/engl.csv \
		tmp/glen.csv \
		src/$(complete_version).title.adoc \
		src/common.adoc
	cat \
		src/$(complete_version).title.adoc \
		src/common.adoc \
		src/$(english_glosa_version).table.adoc \
		src/$(glosa_english_version).table.adoc > $@

target/$(complete_version).list.adoc: \
		tmp/engl.list.adoc \
		tmp/glen.list.adoc \
		src/$(complete_version).title.adoc \
		src/common.adoc
	cat \
		src/$(complete_version).title.adoc \
		src/common.adoc \
		src/$(english_glosa_version).list.adoc \
		src/$(glosa_english_version).list.adoc > $@

target/$(complete_version).paragraph.adoc: \
		tmp/engl.paragraph.adoc \
		tmp/glen.paragraph.adoc \
		src/$(complete_version).title.adoc \
		src/common.adoc
	cat \
		src/$(complete_version).title.adoc \
		src/common.adoc \
		src/$(english_glosa_version).paragraph.adoc \
		src/$(glosa_english_version).paragraph.adoc > $@

target/$(complete_version).linebreak.adoc: \
		tmp/engl.linebreak.adoc \
		tmp/glen.linebreak.adoc \
		src/$(complete_version).title.adoc \
		src/common.adoc
	cat \
		src/$(complete_version).title.adoc \
		src/common.adoc \
		src/$(english_glosa_version).linebreak.adoc \
		src/$(glosa_english_version).linebreak.adoc > $@

#  ---------------------------------------------
#  English-Glosa versions

target/$(english_glosa_version).table.adoc: \
		tmp/engl.csv \
		src/$(english_glosa_version).title.adoc \
		src/common.adoc
	cat \
		src/$(english_glosa_version).title.adoc \
		src/common.adoc \
		src/$(english_glosa_version).table.adoc > $@

target/$(english_glosa_version).list.adoc: \
		tmp/engl.list.adoc \
		src/$(english_glosa_version).title.adoc \
		src/common.adoc
	cat \
		src/$(english_glosa_version).title.adoc \
		src/common.adoc \
		src/$(english_glosa_version).list.adoc > $@

target/$(english_glosa_version).paragraph.adoc: \
		tmp/engl.paragraph.adoc \
		src/$(english_glosa_version).title.adoc \
		src/common.adoc
	cat \
		src/$(english_glosa_version).title.adoc \
		src/common.adoc \
		src/$(english_glosa_version).paragraph.adoc > $@

target/$(english_glosa_version).linebreak.adoc: \
		tmp/engl.linebreak.adoc \
		src/$(english_glosa_version).title.adoc \
		src/common.adoc
	cat \
		src/$(english_glosa_version).title.adoc
		src/common.adoc \
		src/$(english_glosa_version).linebreak.adoc > $@

#  ---------------------------------------------
#  Glosa-English versions

target/$(glosa_english_version).table.adoc: \
		tmp/glen.csv \
		src/$(glosa_english_version).title.adoc \
		src/common.adoc
	cat \
		src/$(glosa_english_version).title.adoc \
		src/common.adoc \
		src/$(glosa_english_version).table.adoc > $@

target/$(glosa_english_version).list.adoc: \
		tmp/glen.list.adoc \
		src/$(glosa_english_version).title.adoc \
		src/common.adoc
	cat \
		src/$(glosa_english_version).title.adoc \
		src/common.adoc \
		src/$(glosa_english_version).list.adoc > $@

target/$(glosa_english_version).paragraph.adoc: \
		tmp/glen.paragraph.adoc \
		src/$(glosa_english_version).title.adoc \
		src/common.adoc
	cat \
		src/$(glosa_english_version).title.adoc \
		src/common.adoc \
		src/$(glosa_english_version).paragraph.adoc > $@

target/$(glosa_english_version).linebreak.adoc: \
		tmp/glen.linebreak.adoc \
		src/$(glosa_english_version).title.adoc \
		src/common.adoc
	cat \
		src/$(glosa_english_version).title.adoc \
		src/common.adoc \
		src/$(glosa_english_version).linebreak.adoc > $@

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
#
# 2018-12-11:
#
# Convert to dict format. The process is not fully working yet.  The notes
# about the Glosa words must be moved to the description field, otherwise it's
# considered part of the word.
#
# 2018-12-12: Move the notes about the Glosa words to the description field.
#
# 2018-12-15: Fix the typo of the description notation of 'akademi' in the
# first tidy. This way later regexp don't need to be modified.
#
# 2018-12-22: Finish the rewritting of most rules. Now most operations are done
# during the first processing of the original data. This makes all later
# recipes easier.
#
# 2018-12-24: Fix minor regexp. Build only EPUB with paragraphs by default.
