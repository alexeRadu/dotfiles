#!/bin/python

import log

# local config files are relative to the root directory
relations = [['./config/bashrc', '~/.bashrc'],
	         ['./config/vimrc',  '~/.vimrc']];

log.info("Synching started")