#!/bin/python
# Clear Trailing Whitespace

import sys
import os
import string

if (len(sys.argv) == 1):
	print "Error: no input file was specified"
	sys.exit(1)

filenames = sys.argv[1:]
for fname in filenames:
	if not os.path.exists(fname):
		print "Error: '{0}' is not a valid file".format(fname)
		sys.exit(1)

	fin = open(fname, "rb")

	outfname = ".tmp.{0}".format(os.path.basename(fname))
	fout = open(outfname, "wb")

	for line in fin:
		line = string.rstrip(line, "\n\t ")
		line += "\n"
		fout.write(line)

	fout.close()
	fin.close()

	os.system("cp {0} {1}".format(outfname, fname))
	os.system("rm {0}".format(outfname))
