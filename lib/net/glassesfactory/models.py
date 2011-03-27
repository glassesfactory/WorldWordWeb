#!/usr/bin/env python
# -*- coding: utf-8 -*-

from google.appengine.ext import db

class ImgData(db.Model):
	img = db.BlobProperty()

class KeywordModel(db.Model):
	keyword = db.StringProperty()
	status = db.StringProperty()
	text = db.StringProperty()
	url = db.URLProperty()
	imgURL = db.URLProperty()
	one = db.StringProperty()
	two = db.StringProperty()
	three = db.StringProperty()
	
class TweetModel(db.Model):
	username = db.StringProperty()
	iconURL = db.StringProperty()
	last = db.IntegerProperty()
	status = db.StringProperty()
	one = db.StringProperty()
	two = db.StringProperty()
	three = db.StringProperty()
	four = db.StringProperty()
	five = db.StringProperty()