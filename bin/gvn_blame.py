#!/usr/bin/env python3

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn


import argparse
import re

import os
import sys

# https://pygments.org/docs/quickstart/
from pygments import highlight
# https://pygments.org/docs/formatters/
from pygments.formatters import TerminalFormatter
from pygments.formatters import TerminalTrueColorFormatter 
from pygments.formatters import Terminal256Formatter
from pygments.lexers import guess_lexer, guess_lexer_for_filename
from pygments.util import ClassNotFound

from inspect import getsourcefile
from os.path import realpath
from os.path import dirname

# add path where script is located to be able to read all submodules
# submodules are expected to be located / must be located parallel to this file !
sys.path.insert(0, dirname(realpath(getsourcefile(lambda:0))))

from tools_c import *
from gvn_exceptions import *

# -----------------------------------------------------------
class bcolors:
    data = {}
    def __init__(self, nocolors, bgalt):
        self.colors_enabled = not nocolors
        self.bgalt = bgalt
        self.data = {}
        self.data['GIT_HASH'] = '\033[33m'
        # self.data['SVN_REV'] = '\033[94m'
        self.data['SVN_REV'] = '\033[1;34m'
        self.data['USER'] = '\033[2;34m'
        self.data['DATETIME'] = '\033[1;32m'
        self.data['LINENR'] = '\033[91m'
        self.data['NO_COLOR'] = '\033[m'
        self.data['WHITE_BG'] = '\033[47m'
        self.data['BRIGHT_WHITE_BG'] = '\033[107m'
        self.data['ITALIC'] = '\033[3m' 
        # 48 	Set background color 	Next arguments are 5;<n> or 2;<r>;<g>;<b>, see below
        self.data['GRAY_BG'] = '\033[48;2;225;225;225m'
        # self.data['NO_COLOR'] = ''

    def get_bgcolor(self, selection):
        if self.colors_enabled and self.bgalt:
            if selection == 0:
                return ""
            else:
                return self.data['GRAY_BG']
        else:
            return ""
        
    def get_color(self, name):
        if self.colors_enabled:
            return self.data[name]
        else:
            return ""
    
# -----------------------------------------------------------
if __name__ == '__main__':
            
    try:
        tools = tools_c() 

        parser = argparse.ArgumentParser()
        parser.add_argument("filename", help="filename to git blame", action="store")
        parser.add_argument("hash", help="hash to use for blaming", action="store", nargs="?", default=None)
        parser.add_argument("--gitsvn", "-s", help="activate git-hash to svn-rev mapping + printing of svn-rev", action="store_true")
        parser.add_argument("--abbrev", "-a", help="select git hash abbreviation width", action="store", type=int)
        parser.add_argument("--bgalt", "-A", help="alternate background color of hash on change, to see different commits easier", action="store_true")
        parser.add_argument("--nocolors", "-n", help="disable color", action="store_true")
        parser.add_argument("--debug", "-d", help="enable debug", action="store_true")
        parser.add_argument("--pygmentize", "-p", help="enable pygmentize code syntax highlighting", action="store_true")
        parser.add_argument("--pygmentize_extern", "-e", help="use external call for pygmentize", action="store_true")
        parser.add_argument("--pygmentize_extern_options", "-o", help="additional options for external pygmentized runs", nargs="+")
        args = parser.parse_args()

        if args.debug:
            print("file: " +  args.filename)
            if args.hash:
                print("hash: " + args.hash)
            # print(' '.join(args.pygmentize_extern_options))

        bc = bcolors(args.nocolors, args.bgalt)
    
        verbose = 0

        # --------------
        if args.gitsvn:
            # get mapping of svn to git
            git_to_svn_map = {}
            svn_rev_width = 0
            command="git log --all --no-color"
            lines = tools.run_external_command_and_get_results(command, verbose)
            for line in lines:
                if m := re.match(r'\s*commit\s+(\S+)(\s+|$)', line):
                    git_hash = m.group(1)
                elif m := re.match(r'\s*git-svn-id:\s+([^\@]+)\@(\d+)\s+', line):
                    svn_rev = m.group(2)
                    git_to_svn_map[git_hash] = svn_rev
                    svn_rev_width = max(svn_rev_width, len(svn_rev))
                    # print(git_hash + " => " + svn_rev)

        # --------------
        command = ("git blame -l --root --date=format-local:'%Y-%m-%d %H:%M:%S' ")

        
        if args.hash:
            command += (" " + args.hash + " ")
        command += args.filename
        lines = tools.run_external_command_and_get_results(command, verbose)

        # ---------------------
        # ^<hash> (<committer name with spaces> <date time> <line_nr>) code$
        r_line = re.compile(r"^([0-9a-fA-F]+)\s+\((.+)\s+(\d+-\d+-\d+\s+\d+:\d+:\d+)\s+(\d+)\)(|\s(.+))$")
        
        # ---------------------
        if args.nocolors:
            pass
        elif args.pygmentize_extern:
            code_syntax_highlighted = {}

            filename = ".tmp.gvn_blame." + args.filename

            linenrs = {}
            lines_code = {}
            
            #try:
            f = open(filename, "w")
            #except:

            linenr = 0
            for line in lines:
                line_m = r_line.match(line)
                if line_m:
                    linenr += 1
                    linenr_code = line_m.group(4);
                    code = line_m.group(5);
                    
                    linenrs[linenr] = linenr_code
                    lines_code[linenr] = code
                    if args.debug:
                        print("linenr map: " + str(linenr) + " <=> " + linenr_code)
                    print(code, file=f)
            f.close()

            command = "pygmentize "
            if args.pygmentize_extern_options:
                command += ' '.join(args.pygmentize_extern_options)
            command += " -g " + filename

            lines2 = tools.run_external_command_and_get_results(command, verbose)

            linenr2 = 0
            for line in lines2:
                linenr2 += 1
                linenr_code = linenrs[linenr2]
                if args.debug:
                    print("found linenr in highlighted: " + linenr_code)

                code_syntax_highlighted[linenr_code] = line.rstrip()
                # print(str(linenr) + ": " + line)
            
            # fix below is required to get it clean in case of line breaks at end of
            while linenr2 < linenr:
                linenr2 += 1
                linenr_code = linenrs[linenr2]
                code_syntax_highlighted[linenr_code] = lines_code[linenr2]
                
            if not args.debug:
                os.remove(filename)
            
        elif args.pygmentize:
            code_syntax_highlighted = {}
            lexer = None
            try:
                lexer = guess_lexer_for_filename(args.filename, lines)
                if args.debug:
                    print("pygmentize guessed lexer: " + str(lexer))
            except ClassNotFound:
                pass
            
            formatter = TerminalFormatter()

            for line in lines:
                line_m = r_line.match(line)
                if line_m:
                    linenr = line_m.group(4);
                    code = line_m.group(5);
                    if args.debug:
                        print("found linenr in highlighted: " + linenr)
                   
                    if lexer:
                        result = highlight(code, lexer, formatter)
                        code_syntax_highlighted[linenr] = result.rstrip()
                    else:
                        code_syntax_highlighted[linenr] = code

        user_width = 0
        for line in lines:
            line_m = r_line.match(line)
            if line_m:
                user_width = max(user_width, len(line_m.group(2)))
                
        git_hash_prev = ""
        marker = 0
        
        for line in lines:
            # ^<hash> (<committer name with spaces> <date time> <line_nr>) code$
            line_m = r_line.match(line)
            if line_m:

                git_hash = line_m.group(1)
                if git_hash != git_hash_prev:
                    if marker == 0:
                        marker = 1
                    else:
                        marker = 0
                git_hash_prev = git_hash
                
                git_hash_short = git_hash
                if args.abbrev:
                    git_hash_short = git_hash[0:args.abbrev]

                to_print = ""
                to_print +=  bc.get_bgcolor(marker) + bc.get_color('GIT_HASH') + git_hash_short + bc.get_color('NO_COLOR') + " "
                if args.gitsvn:
                    if git_hash in git_to_svn_map:
                        svn_rev = "r" + git_to_svn_map[git_hash]
                    else:
                        svn_rev = "r???"
                    to_print += bc.get_color('SVN_REV') + '{:>{srw}}'.format(svn_rev, srw = svn_rev_width) + bc.get_color('NO_COLOR') + " "
                to_print += bc.get_color('USER') + '{:>{usrw}}'.format(line_m.group(2), usrw = user_width) + bc.get_color('NO_COLOR') + " "
                to_print += bc.get_color('DATETIME') + line_m.group(3) + bc.get_color('NO_COLOR') + " "
                to_print += bc.get_color('LINENR') + '{:>5}'.format(line_m.group(4)) + bc.get_color('NO_COLOR') + " "
                to_print += "| "
                if args.nocolors:
                    to_print += line_m.group(5)
                elif args.pygmentize:
                    linenr = line_m.group(4)
                    if args.debug:
                        print("search linenr in highlighted: " + linenr)
                    to_print += code_syntax_highlighted[linenr]
                else:
                    to_print += line_m.group(5)

                print(to_print)

    except KeyboardInterrupt:
        print("\n")
        the_tools.error("User Abort detected.")
        #    except ToolException as e:
        #        the_tools.error("Uncatched Tool Error detected:\n " + str(e)) # this should not happen but catch it here just in case
    except GVNException as e:
        the_tools.error("Error detected:\n " + str(e))
        #    except BaseException as e:
        #        the_tools.error("Fatal Uncatched Error detected:\n " + str(e))
