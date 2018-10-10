#!/bin/bash

export CGI_BIN=$HOME/examples/cgi-bin

eval "$(perl -Mlocal::lib=$CGI_BIN/perl5)"

"$CGI_BIN/bz.pl" --weekly $@
