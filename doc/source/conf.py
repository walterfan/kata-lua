# Configuration file for the Sphinx documentation builder.

project = 'Lua 实战开发指南'
copyright = '2026, Walter Fan, Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License'
author = 'Walter Fan'
release = '1.0'

extensions = [
    'myst_parser',
    'sphinx_design',
    'sphinx_copybutton',
    'sphinxcontrib.mermaid',
]

templates_path = ['_templates']
exclude_patterns = []

html_theme = 'sphinx_rtd_theme'
html_static_path = []

source_suffix = {
    '.rst': 'restructuredtext',
    '.txt': 'markdown',
    '.md': 'markdown',
}

myst_enable_extensions = [
    'colon_fence',
    'deflist',
    'fieldlist',
    'tasklist',
]
