# \ var
MODULE  = $(notdir $(CURDIR))
OS      = $(shell uname -s)
MACHINE = $(shell uname -m)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES   = $(shell grep processor /proc/cpuinfo| wc -l)
# / var

# \ dir
CWD     = $(CURDIR)
BIN     = $(CWD)/bin
DOC     = $(CWD)/doc
TMP     = $(CWD)/tmp
LIB     = $(CWD)/lib
SRC     = $(CWD)/src
TEST    = $(CWD)/test
GZ      = $(HOME)/gz
CAR     = $(HOME)/.cargo/bin
# / dir

# \ tool
CURL    = curl -L -o
CARGO   = $(CAR)/cargo
RUSTC   = $(CAR)/rustc
RUSTUP  = $(CAR)/rustup
# / tool

# \ src
R += $(shell find src -type f -regex ".+.rs$$")
S += $(R)
# / src

# \ all
.PHONY: all
all: bin/$(MODULE) lib/$(MODULE).ml
	$^

.PHONY: repl
repl:

.PHONY: test
test:

.PHONY: format
format: tmp/format
tmp/format: $(R)
	cargo fmt
	touch $@

bin/$(MODULE): $(R) Makefile
	cargo build && cp target/debug/rtris $@
	$(MAKE) format
# / all

# \ doc
.PHONY: doc
doc:

.PHONY: doxy
doxy: doxy.gen
	doxygen $< 1>/dev/null
# / doc

# \ install
.PHONY: install update
install: $(OS)_install doc
	$(MAKE) $(CARGO)
	$(MAKE) update
update: $(OS)_update
	$(RUSTUP) update
	$(CARGO)  update

.PHONY: Linux_install Linux_update
Linux_install Linux_update:
	sudo apt update
	sudo apt install -u `cat apt.txt`
$(CARGO):
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# / install

# \ merge
MERGE  = README.md LICENSE Makefile .gitignore apt.txt apt.dev .vscode $(S)
MERGE += bin doc tmp
MERGE += static templates

.PHONY: zip
zip:
	git archive \
		--format zip \
		--output $(TMP)/$(MODULE)_$(BRANCH)_$(NOW)_$(REL).src.zip \
	HEAD

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout ponymuck -- $(MERGE)

.PHONY: ponymuck
ponymuck:
	git push -v
	git checkout $@
	git pull -v
# / merge
