#!/usr/bin/env python3

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

import argparse
import re

import os
import sys

from inspect import getsourcefile
from os.path import realpath
from os.path import dirname

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
        parser.add_argument("--nocolors", "-n", help="disable color", action="store_true")
        parser.add_argument("--debug", "-d", help="enable debug", action="store_true")
        parser.add_argument("--read_from_map_db", "-m", help="read svn revision mapping to git hash from mapping db file", action="store_true")
        args = parser.parse_args()

        # ---------------------
        bc = gvn_colors(args.nocolors)
        base = gvn_base(tools, args.debug, verbose)

        if args.read_from_map_db:
          command="git get-dot-git-path"
          result = subprocess.run(command.split(), stdout=subprocess.PIPE)
          db_filename = result.stdout.decode().rstrip() + '/gvn/rev/db'
          base.read_from_json_file(db_filename)
        else:
          base.init_hash_to_svn_rev()
        
        # ---------------------
        re_hash = re.compile(r'^(.+?)(\<hash\>([^\<]+)\<\/hash\>)(.+?)$')

        for line_all in sys.stdin:
            line = line_all.rstrip('\n')
            m = re_hash.match(line)
            if m:
                print( m.group(1) + \
                       bc.get_color('SVN_REV') + \
                       base.map_git_hash_to_svn_rev_print(m.group(3)) + \
                       bc.get_color('NO_COLOR') + \
                       m.group(4) )
            else:
                print(line)

    except KeyboardInterrupt:
        print("\n")
        tools.error("User Abort detected.")
        #    except ToolException as e:
        #        the_tools.error("Uncatched Tool Error detected:\n " + str(e)) # this should not happen but catch it here just in case
    except GVNException as e:
        tools.error("Error detected:\n " + str(e))
        #    except BaseException as e:
        #        the_tools.error("Fatal Uncatched Error detected:\n " + str(e))
