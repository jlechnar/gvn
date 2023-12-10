# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

class gvn_colors:
    data = {}
    def __init__(self, nocolors, bgalt=False):
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
