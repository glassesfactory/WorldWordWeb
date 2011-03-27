#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 2011/03/21

@author: MEGANE
'''
import django.utils.simplejson as json
import urllib2
import urllib
import re

from morpho_util import Morpho
from net.glassesfactory.models import KeywordModel

class newsloader(object):
    def load(self, keyword):
        encKey = urllib.quote(keyword.encode('utf-8'))
        reqURL = ('https://ajax.googleapis.com/ajax/services/search/news?' +
       'v=1.0&key=ABQIAAAAzk2wmP0-QkezFZB4jKCidxTgNOgp-MR3hNxNEPAaDYM58TmiQRTDWA1p4xA7dYYta0tbq7J-_pb0UA&hl=ja&rsz=8&q=')
        
        req = urllib2.Request(reqURL + encKey, None, {'Referer':'http:/127.0.0.1:8080'})
        response = urllib2.urlopen(req)
        
        results = parse_json(response)
        contents = results['responseData']['results']
        str = ''
        
        for content in contents:
            str += content['titleNoFormatting']
            p = re.compile('[!-@[-`{-~]')
            str = p.sub('', str )
            p = re.compile(u'[！”＃＄％＆’（）＝～｜‘｛＋＊｝＜＞？＿－＾￥＠「；：」、。・]')
            str = p.sub('', str)
            str = str.replace(unicode(keyword), '')
        
        morpho = Morpho()
        strs = morpho.analyze(str,3)
        
        hasImg = False
        index = 0
        
        model = KeywordModel()
        model.keyword = keyword
        model.one = strs[0][1]
        model.two = strs[1][1]
        model.three = strs[2][1]
        
        try:
            for content in contents:
                if content['image']:
                    model.text = content['titleNoFormatting']
                    model.imgURL = content['image']['url']
                    model.url = content['image']['originalContextUrl']
                    model.status = 'Success'
                    break
                else:
                   model.text = content['titleNoFormatting']
                   model.url = content['image']['originalContextUrl']
        except:
            model.status = 'News Analyze Error'
        if not model.text:
                model.text = contents[0]['titleNoFormatting']
                model.url = urllib2.unquote(contents[0]['url']).encode('raw_unicode_escape').decode('utf-8')
        model.put()
        return model
    
def parse_json(json_str):
    obj = json.load(json_str)
    return obj
