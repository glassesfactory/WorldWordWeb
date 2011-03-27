#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 2011/03/18

@author: MEGANE
'''

from werkzeug import redirect, Request
from kay.utils import (
  render_to_response, url_for
)

from google.appengine.ext import db
from google.appengine.api import memcache

from net.glassesfactory.simple_cookie import Cookies
from net.glassesfactory.models import TweetModel
from morpho_util import Morpho
from pyamf.amf3 import ByteArray

import tweepy
import config
import settings
import urllib2
import re


class RequestToken(db.Model):
    token_key = db.StringProperty(required=True)
    token_secret = db.StringProperty(required=True)


 
class tweetloader(object):
      def load(self, sid, username=''):
        strs = []
        mozi = ''
        tweetModel = TweetModel()
        access_token = memcache.get(sid)
        if access_token:
            try:
                auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET)
                auth.set_access_token(access_token.key, access_token.secret)
            
                if username == '':
                    username = auth.get_username()
            
                api = tweepy.API(auth_handler = auth)
                
                for tweet in tweepy.Cursor(api.user_timeline, screen_name = username, count = 500).items(100):
                    p = re.compile('(@)(\w+)')
                    text = p.sub('', tweet.text)
                    p = re.compile('[!-@[-`{-~]')
                    text = p.sub('', text )
                    p = re.compile(u'[！”＃＄％＆’（）＝～｜‘｛＋＊｝＜＞？＿－＾￥＠「；：」、。・]')
                    text = p.sub('', text)
                    mozi += text
               
                morpho = Morpho()
                strs = morpho.analyze(mozi)
                iconURL = api.me().profile_image_url
                
                try:
                    if iconURL.index('_normal'):
                       iconURL = iconURL.replace( '_normal', '' )
                except:
                    pass
                
                tweetModel.username = username
                tweetModel.iconURL = iconURL
                tweetModel.status = 'Success'
                tweetModel.one = strs[0][1]
                tweetModel.two = strs[1][1]
                tweetModel.three = strs[2][1]
                tweetModel.four = strs[3][1]
                tweetModel.five = strs[4][1]
                tweetModel.put()
            except:
                tweetModel.status = 'Authentication Error'
                tweetModel.put()
        return tweetModel

class tweetFuller(object):
    def load(self, sid, username=''):
            strs = []
            mozi = ''
            tweetModel = TweetModel()
            access_token = memcache.get(sid)
            if access_token:
                try:
                    auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET)
                    auth.set_access_token(access_token.key, access_token.secret)
                
                    if username == '':
                        username = auth.get_username()
                
                    api = tweepy.API(auth_handler = auth)
                    
                    for tweet in tweepy.Cursor(api.user_timeline, screen_name = username, count = 500).items(100):
                        p = re.compile('(@)(\w+)')
                        text = p.sub('', tweet.text)
                        p = re.compile('[!-@[-`{-~]')
                        text = p.sub('', text )
                        p = re.compile(u'[！”＃＄％＆’（）＝～｜‘｛＋＊｝＜＞？＿－＾￥＠「；：」、。・]')
                        text = p.sub('', text)
                        mozi += text
                   
                    morpho = Morpho()
                    strs = morpho.analyze(mozi, 200)
                except:
                    pass  
            return strs     
                    
"""OAuth"""     
def OAuth(request):
    auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET, config.CALLBACK_URL)
    auth_url = auth.get_authorization_url()
    request_token = RequestToken(token_key = auth.request_token.key, token_secret = auth.request_token.secret)
    request_token.put()
    return redirect(auth_url)
        

def OAuthCB(request):
    request_token_key = request.args.get("oauth_token")
    request_verifier = request.args.get("oauth_verifier")
    auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET)
    request_token = RequestToken.gql("WHERE token_key=:1", request_token_key).get()
    auth.set_request_token(request_token.token_key, request_token.token_secret)
    access_token = auth.get_access_token(request_verifier)
    cookie = request.cookies
    memcache.set(cookie['KAY_SESSION'],access_token, config.SESSION_EXPIRE)
    return redirect('/redirect')



"""
class Update(webapp.RequestHandler):
    def post(self):
        cookie = Cookies(self)
        access_token = memcache.get(cookie['sid'])
        if access_token:
            auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET)
            auth.set_access_token(access_token.key, access_token.secret)
            api = tweepy.API(auth_handler = auth)
            api.update_status(status =self.response.get('status'))
        self.redirect('/')
"""
