#!/bin/sh

CFLAGS="-O2 -fno-tree-dce -fno-optimize-sibling-calls" \
CPPFLAGS=-I/opt/X11/include \
RUBY_CONFIGURE_OPTS=--with-openssl-dir="$(brew --prefix openssl)" \
rbenv install ree-1.8.7-2012.02