#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# -*- coding: utf-8 -*-

from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.ext import db

import wsgiref.handlers
from net.glassesfactory.models import AMFImgData
from pyamf.remoting.gateway.wsgi import WSGIGateway
from pyamf.amf3 import ByteArray

class MainHandler(webapp.RequestHandler):
	def get(self):
		self.response.out.write('Hello world!')

def putImgData(data):
	imgModel = AMFImgData()
	imgModel.img = db.Blob(str(data));
	imgModel.put()
	return imgModel.img
	


def main():
	
	services = {
		'putImgData':putImgData,
	}
	
	application = WSGIGateway(services)
	wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
	main()
