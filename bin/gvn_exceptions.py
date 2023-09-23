# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

class GVNException(Exception):
    name = "GVNException"
    message = ""

    def __init__(self, message):
        self.message = message

    def __str__(self):
        if self.message:
            return self.name + ': ' + self.message
        else:
            return self.name + ' has been raised'

class GVNExceptionParseError(GVNException):
    name = "GVNExceptionParseError"

class GVNExceptionInternalFatalError(GVNException):
    name = "GVNExceptionInternalFatalError"

class GVNExceptionDecode(GVNException):
    name = "GVNExceptionDecode"

class GVNExceptionAbort(GVNException):
    name = "GVNExceptionAbort"

class GVNExceptionSelect(GVNException):
    name = "GVNExceptionSelect"

class GVNExceptionExecute(GVNException):
    name = "GVNExceptionExecute"

