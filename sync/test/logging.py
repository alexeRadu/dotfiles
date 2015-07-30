#!/bin/python

import sys
sys.path.append("../");

import log


log.info("Testing logging")
log.info("")
log.diff_plus("diff plus")
log.diff_minus("diff minus")
log.info("Info")
log.debug("Debug")
log.warn("Warning")
log.err("Error")

log.disable()
log.info("After disabling")
log.info("")
log.diff_plus("diff plus")
log.diff_minus("diff minus")
log.info("Info")
log.debug("Debug")
log.warn("Warning")
log.err("Error")

log.enable()
log.info("After enabling")
log.info("")
log.diff_plus("diff plus")
log.diff_minus("diff minus")
log.info("Info")
log.debug("Debug")
log.warn("Warning")
log.err("Error")