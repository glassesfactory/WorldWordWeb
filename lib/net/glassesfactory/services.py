'''
Created on 2011/03/23

@author: MEGANE
'''

from net.glassesfactory.twitter import LoadAMF
from google.appengine.api import memcache
from net.glassesfactory.simple_cookie import Cookies

import config

class LoadTweet(object):
    def load(self):
        loader = LoadAMF()
        loader.load()

class AuthCheck(object):
    def isAuth(self):
        cookie = Cookies(self, max_age = config.SESSION_EXPIRE)
        isAuth = False
        if memcache.get(cookie['sid']):
            isAuth = True
        return isAuth