#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 2011/03/18

@author: MEGANE

形態素解析実行用モジュール
'''

import igo.Tagger
import os
import kay
import re

class MorphoModel(object):
    def __init__(self, surface, feature, start):
        self.surface = surface
        self.feature = feature
        self.start = start

t = igo.Tagger.Tagger(os.path.join(kay.PROJECT_DIR,"ipadic"),gae=True)
regexp = re.compile(u'名詞')
regkana = re.compile(u'[あ-んー]')
regNum = re.compile('[0-9]')

class Morpho(object):
    
    def parse(self, text ):
        l = t.parse(text)
        strs = []
        
        for m in l:
            str = MorphoModel( m.surface, m.feature, m.start )
            strs.append(str)
        
        return strs
    
    def analyze(self, text, count = 5):
        l = t.parse(text)
        dict = {}
        for m in l:
            type = m.feature
            result = regexp.search(unicode(m.feature))
            str = m.surface
            result2 = None
            resultNum = None
            if not len(str) > 1: 
                result2 = regkana.search(unicode(m.surface))
                resultNum = regNum.search(m.surface)
            if result and not result2 and not resultNum: 
                dict[m.surface] = dict.get(m.surface,0) + 1
                
        d = [(v,k) for k,v in dict.items()]
        d.sort()
        d.reverse()
        del d[count:]
        return d

