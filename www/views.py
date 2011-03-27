# -*- coding: utf-8 -*-
"""
www.views
"""

from google.appengine.api import memcache
from werkzeug import Request
from kay.utils import render_to_response

import pyamf
from pyamf import amf3
from pyamf.remoting.gateway.wsgi import WSGIGateway

import twitter
from twitter import tweetloader, tweetFuller
from net.glassesfactory.image_util import ImageUtil
import news
from news import newsloader

import uuid
from morpho_util import Morpho
import config
# Create your views here.

sid = ''


class authCheck(object):
    def isAuth(self, sid ):
        if memcache.get(str(sid)):
            return True
        return False


import uuid
class uidGenerator(object):
    def generate(self):
        return sid 


def index(request):
    cookie = request.session
    if not cookie.has_key('sid'):
        cookie['sid'] = str(uuid.uuid4())
    return render_to_response('www/index.html')


def gateway(request):
    services = {
        'authCheck':authCheck,
        'uidGenerator':uidGenerator,
        'tweetloader':tweetloader,
        'tweetFuller':tweetFuller,
        'imageutil':ImageUtil,
        'newsloader':newsloader,
    }
    return WSGIGateway(services)


def crossdomain(request):
    return render_to_response('www/crossdomain.xml')


def redirectParent(request):
    return render_to_response('www/oauthcb.html')


def morphotest(request):
    strs = []
    morpho = Morpho()
    strs = morpho.analyze( u'めがねもめがね、めがめがね')
    return render_to_response('www/mp.html', {'strs':strs})


from werkzeug import redirect
def toIndex(request):
    return redirect('/')


def txd(request):
    return render_to_response('www/txd.html')
