#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 2011/03/25

@author: MEGANE
'''

from pyamf.amf3 import ByteArray
import urllib2
from google.appengine.api import images


class ImageUtil(object):
    def load(self, url):
        try:
            img = urllib2.urlopen(url).read()
            bytes = ByteArray()
            bytes.write(img)
            return bytes
        except:
            return "Image request Error" 
    
    def loadThumb(self, url, size):
        try:
            buffer = urllib2.urlopen(url).read()
            img = images.resize(buffer, size, size)
            bytes = ByteArray()
            bytes.write(img)
            return bytes
        except:
            return "Image request Error"
        
        
