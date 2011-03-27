#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 2011/03/23

@author: MEGANE
'''
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from net.glassesfactory.services import LoadTweet
from net.glassesfactory.services import AuthCheck
from pyamf.remoting.gateway.wsgi import WSGIGateway

class crossdomain(webapp.RequestHandler):  
    def get(self):
        self.response.out.write(template.render('view/crossdomain.xml', {}))

def hoge():
    return 'hoge'
    
class gateway(webapp.RequestHandler):
    def get(self):
        services = {
                    'loadTweet':LoadTweet,
                    'authCheck':AuthCheck.isAuth,
                    'hoge':hoge
                    }
       # return WSGIGateway(services)
    
