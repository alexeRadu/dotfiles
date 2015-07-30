#!/bin/python

_DEFAULT_COLOR_DIFF_PLUS  = "\033[92m" 	# green
_DEFAULT_COLOR_DIFF_MINUS = "\033[91m" 	# red
_DEFAULT_COLOR_DEBUG 	  = "\033[95m" 	# yellow
_DEFAULT_COLOR_WARN 	  = "\033[94m" 	# ???
_DEFAULT_COLOR_ERR 		  = "\033[91m" 	# red
_DEFAULT_COLOR_END		  = "\033[0m"


_COLOR_DIFF_PLUS  = _DEFAULT_COLOR_DIFF_PLUS
_COLOR_DIFF_MINUS = _DEFAULT_COLOR_DIFF_MINUS
_COLOR_DEBUG 	  = _DEFAULT_COLOR_DEBUG
_COLOR_WARN 	  = _DEFAULT_COLOR_WARN
_COLOR_ERR 		  = _DEFAULT_COLOR_ERR
_COLOR_END		  = _DEFAULT_COLOR_END


def disable():
	global _COLOR_DIFF_PLUS
	global _COLOR_DIFF_MINUS
	global _COLOR_DEBUG
	global _COLOR_WARN
	global _COLOR_ERR
	global _COLOR_END

	_COLOR_DIFF_PLUS  = ""
	_COLOR_DIFF_MINUS = ""
	_COLOR_DEBUG 	  = ""
	_COLOR_WARN 	  = ""
	_COLOR_ERR 		  = ""
	_COLOR_END		  = ""

def enable():
	global _COLOR_DIFF_PLUS
	global _COLOR_DIFF_MINUS
	global _COLOR_DEBUG
	global _COLOR_WARN
	global _COLOR_ERR
	global _COLOR_END
	
	_COLOR_DIFF_PLUS  = _DEFAULT_COLOR_DIFF_PLUS
	_COLOR_DIFF_MINUS = _DEFAULT_COLOR_DIFF_MINUS
	_COLOR_DEBUG 	  = _DEFAULT_COLOR_DEBUG
	_COLOR_WARN 	  = _DEFAULT_COLOR_WARN
	_COLOR_ERR 		  = _DEFAULT_COLOR_ERR
	_COLOR_END		  = _DEFAULT_COLOR_END


def diff(msg):
	print msg

def diff_plus(msg):
	print _COLOR_DIFF_PLUS + " + " + msg + _COLOR_END

def diff_minus(msg):
	print _COLOR_DIFF_MINUS + " - " + msg + _COLOR_END

def info(msg):
	print msg

def debug(msg):
	print _COLOR_DEBUG + msg + _COLOR_END

def warn(msg):
	print _COLOR_WARN + msg + _COLOR_END

def err(msg):
	print _COLOR_ERR + msg + _COLOR_END