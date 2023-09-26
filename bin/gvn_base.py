# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

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
        lines = self.tools.run_external_command_and_get_results(command, self.verbose)

        re_commit = re.compile(r'^\s*commit\s+(\S+)(\s|$)')
        re_git_svn_id = re.compile(r'^\s*git-svn-id:\s+([^\@]+?)\@(\d+)\s')

        for line in lines:
            m1 = re_commit.match(line)
            m2 = re_git_svn_id.match(line)
            if m1:
                git_hash = m1.group(1)
            elif m2:
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
