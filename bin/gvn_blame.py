#!/usr/bin/env python3

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn


import argparse
import re

import os
import subprocess
from subprocess import run
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
from os.path import splitext

# add path where script is located to be able to read all submodules
# submodules are expected to be located / must be located parallel to this file !
sys.path.insert(0, dirname(realpath(getsourcefile(lambda:0))))

from tools_c import *
from gvn_exceptions import *
from gvn_colors import *
from gvn_base import *
  
# -----------------------------------------------------------
if __name__ == '__main__':
            
    try:
        # -------------------------------------
        verbose = 0
        tools = tools_c() 

        # -------------------------------------
        parser = argparse.ArgumentParser()
        parser.add_argument("filename", help="filename to git blame", action="store")
        parser.add_argument("hash", help="hash to use for blaming", action="store", nargs="?", default=None)
        parser.add_argument("--gitsvn", "-s", help="activate git-hash to svn-rev mapping + printing of svn-rev", action="store_true")
        parser.add_argument("--abbrev", "-a", help="select git hash abbreviation width", action="store", type=int)
        parser.add_argument("--bgalt", "-A", help="alternate background color of hash on change, to see different commits easier", action="store_true")
        parser.add_argument("--nocolors", "-n", help="disable color", action="store_true")
        parser.add_argument("--debug", "-d", help="enable debug", action="store_true")
        parser.add_argument("--verbose", "-v", help="enable verbose", action="store_true")
        parser.add_argument("--pygmentize", "-p", help="enable pygmentize code syntax highlighting", action="store_true")
        parser.add_argument("--pygmentize_extern", "-e", help="use external call for pygmentize", action="store_true")
        parser.add_argument("--pygmentize_extern_options", "-o", help="additional options for external pygmentized runs", nargs="+")
        parser.add_argument("--read_from_map_db", "-m", help="read svn revision mapping to git hash from mapping db file", action="store_true")
        args = parser.parse_args()

        # --------------
        bc = gvn_colors(args.nocolors, args.bgalt)
        base = gvn_base(tools, args.debug, verbose)

        if args.verbose:
          verbose = 1

        # --------------
        if args.debug:
            tools.debug("file: " +  args.filename)
            if args.hash:
                tools.debug("hash: " + args.hash)
            # tools.debug(' '.join(args.pygmentize_extern_options))
        
        # --------------
        if args.gitsvn:
          if args.read_from_map_db:
            command="git get-dot-git-path"
            result = subprocess.run(command.split(), stdout=subprocess.PIPE)
            db_filename = result.stdout.decode().rstrip() + '/gvn/rev/db'
            base.read_from_json_file(db_filename)
          else:
            base.init_hash_to_svn_rev()
            
        # --------------
        command = ("git blame -l --root --date=format-local:'%Y-%m-%d<SPACE>%H:%M:%S' ")

        
        if args.hash:
            command += (" " + args.hash + " ")
        command += args.filename

        if args.verbose:
            tools.info(command)
        if args.debug:
            tools.debug(str(command.split()))
        
        p = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        lines = []
        for line_undecoded in p.stdout:
            line = (line_undecoded.decode()).rstrip()
            lines += [line]
           
        # ---------------------
        # ^<hash> (<committer name with spaces> <date time> <line_nr>) code$
        r_line = re.compile(r"^([0-9a-fA-F]+)\s+(\S+\s+)?\((.+)\s+\'(\d+-\d+-\d+)<SPACE>(\d+:\d+:\d+)\'\s+(\d+)\)(|\s(.+))$")
        
        # ---------------------
        if args.nocolors:
            pass
        elif args.pygmentize_extern:
            code_syntax_highlighted = {}

            filename_extension = os.path.splitext(args.filename)[1]
            filename = args.filename + ".tmp.gvn_blame." + filename_extension

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
                    linenr_code = line_m.group(6);
                    code = line_m.group(7);
                    
                    linenrs[linenr] = linenr_code
                    lines_code[linenr] = code
                    if args.debug:
                        tools.debug("linenr map: " + str(linenr) + " <=> " + linenr_code)
                    print(code, file=f)
            f.close()

            if args.verbose:
                tools.info("Line Numbers:" + str(linenr))
            
            command2 = "pygmentize "
            if args.pygmentize_extern_options:
                command2 += ' '.join(args.pygmentize_extern_options)
            command2 += " -g " + filename

            if args.debug:
                tools.debug('\n'.join(lines))

            linenr2 = 0

            p = subprocess.Popen(command2.split(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            for line_undecoded in p.stdout:
                line = line_undecoded.decode()

                linenr2 += 1
                linenr_code = linenrs[linenr2]
                if args.debug:
                    tools.debug("found linenr in highlighted: " + linenr_code)

                code_syntax_highlighted[linenr_code] = line.rstrip()
                # print(str(linenr) + ": " + line)

            if args.verbose:
                tools.info("Line Numbers:" + str(linenr2))
            
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
                if args.verbose:
                    tools.info("pygmentize guessed lexer: " + str(lexer))
            except ClassNotFound:
                pass
            
            formatter = TerminalFormatter()

            for line in lines:
                line_m = r_line.match(line)
                if line_m:
                    linenr = line_m.group(6);
                    code = line_m.group(7);
                    if args.debug:
                        tools.debug("found linenr in highlighted: " + linenr)
                   
                    if lexer:
                        result = highlight(code, lexer, formatter)
                        code_syntax_highlighted[linenr] = result.rstrip()
                    else:
                        code_syntax_highlighted[linenr] = code

        user_width = 0
        for line in lines:
            line_m = r_line.match(line)
            if line_m:
                user_width = max(user_width, len(line_m.group(3)))
                
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
                    to_print += bc.get_color('SVN_REV') + base.map_git_hash_to_svn_rev_print(git_hash) + bc.get_color('NO_COLOR') + " "
                to_print += bc.get_color('USER') + '{:>{usrw}}'.format(line_m.group(3), usrw = user_width) + bc.get_color('NO_COLOR') + " "
                to_print += bc.get_color('DATETIME') + line_m.group(4) + " " + line_m.group(5)  + bc.get_color('NO_COLOR') + " "
                to_print += bc.get_color('LINENR') + '{:>5}'.format(line_m.group(6)) + bc.get_color('NO_COLOR') + " "
                to_print += "| "
                if args.nocolors:
                    to_print += line_m.group(7)
                elif args.pygmentize:
                    linenr = line_m.group(6)
                    if args.debug:
                        tools.debug("search linenr in highlighted: " + linenr)
                    to_print += code_syntax_highlighted[linenr]
                else:
                    to_print += line_m.group(7)

                print(to_print)

    except KeyboardInterrupt:
        print("\n")
        tools.error("User Abort detected.")
        #    except ToolException as e:
        #        the_tools.error("Uncatched Tool Error detected:\n " + str(e)) # this should not happen but catch it here just in case
    except GVNException as e:
        tools.error("Error detected:\n " + str(e))
        #    except BaseException as e:
        #        the_tools.error("Fatal Uncatched Error detected:\n " + str(e))
