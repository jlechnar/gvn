# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

import json
import os.path
import subprocess
from tools_c import *
# from gvn_exceptions import *
# from gvn_colors import *

class gvn_base:

    def __init__(self, tools, debug, verbose):
        self.debug = debug
        self.tools = tools
        self.verbose = verbose

    def init_hash_to_svn_rev(self):
        # get mapping of svn to git
        self.git_to_svn_map = {}
        self.svn_rev_width = 1
        
        command="git log --all --no-color"
        # lines = self.tools.run_external_command_and_get_results(command, self.verbose)

        re_commit = re.compile(r'^\s*commit\s+(\S+)(\s|$)')
        re_git_svn_id = re.compile(r'^\s*git-svn-id:\s+([^\@]+?)\@(\d+)\s')

        p = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for line_undecoded in p.stdout:
            line = line_undecoded.decode()
            
            m1 = re_commit.match(line)
            if m1:
                git_hash = m1.group(1)
            else:
                m2 = re_git_svn_id.match(line)
                if m2:
                    svn_rev = m2.group(2)
                    self.git_to_svn_map[git_hash] = svn_rev
                    self.svn_rev_width = max(self.svn_rev_width, len(svn_rev))
                    if self.debug:
                        self.tools.warn_debug(git_hash + " => " + svn_rev)
                        self.tools.debug(git_hash + " => " + svn_rev)

    def map_git_hash_to_svn_rev(self, git_hash):
        if git_hash in self.git_to_svn_map:
            svn_rev = "r" + self.git_to_svn_map[git_hash]
        else:
            svn_rev = "r"
            for i in range(0, self.svn_rev_width):
                svn_rev += "?"
        return svn_rev

    def map_git_hash_to_svn_rev_print(self, git_hash):
        return '{:>{srw}}'.format(self.map_git_hash_to_svn_rev(git_hash), srw = self.svn_rev_width + 1)

    def write_to_json_file(self, filepathname):
      filename = filepathname + '.json'
      with open(filename, 'w') as f:
        json.dump([self.svn_rev_width, self.git_to_svn_map], f)

    def read_from_json_file(self, filepathname):
      filename = filepathname + '.json'
      if os.path.isfile(filename) : 
        with open(filename, 'r') as f:
          data =  json.load(f)
        self.svn_rev_width = data[0]
        self.git_to_svn_map = data[1]
      else:
        raise GVNException("ERROR: Could not read json data from none existing file: <" + filename + ">.")

