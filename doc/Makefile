# Makefile for Sphinx documentation
#
# Lua 实战开发指南

SPHINXOPTS  ?=
VENV_BIN    := $(abspath ../.venv/bin)
SPHINXBUILD ?= $(if $(wildcard $(VENV_BIN)/sphinx-build),$(VENV_BIN)/sphinx-build,sphinx-build)
SOURCEDIR   = source
BUILDDIR    = build

.PHONY: help install livehtml clean-all serve dev quick html

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)

# macOS ships GNU Make 3.81, which ignores a match-anything pattern rule
# for a target that is only listed in .PHONY. html needs an explicit recipe.
html:
	$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)

install:
	pip install -r requirements.txt

livehtml:
	sphinx-autobuild "$(SOURCEDIR)" "$(BUILDDIR)/html" $(SPHINXOPTS) $(O)

clean-all:
	rm -rf $(BUILDDIR)/*

serve:
	cd $(BUILDDIR)/html && python3 -m http.server 8000

dev: html serve

quick:
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" -j auto $(SPHINXOPTS) $(O)
