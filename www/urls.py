# -*- coding: utf-8 -*-
# www.urls
# 

# Following few lines is an example urlmapping with an older interface.
from werkzeug.routing import EndpointPrefix, Rule
import www.views
import www.twitter

def make_rules():
  return [
    EndpointPrefix('www/', [
      Rule('/', endpoint='index'),
      Rule('/WorldWordWeb.html', endpoint='toindex'),
      Rule('/TwitterXDomainSample.html', endpoint='txd'),
      Rule('/gateway', endpoint='gateway'),
      Rule('/crossdomain.xml',endpoint='crossdomain'),
      Rule('/oauth', endpoint = 'oauth'),
      Rule('/oauth_cb', endpoint ='oauth_cb'),
      Rule('/redirect', endpoint='redirect'),
      Rule('/morpho', endpoint='morpho'),
    ]),
  ]

all_views = {
  'www/index': www.views.index,
  'www/toindex': www.views.toIndex,
  'www/txd':www.views.txd,
  'www/gateway': www.views.gateway,
  'www/crossdomain.xml': www.views.crossdomain,
  'www/oauth': www.twitter.OAuth,
  'www/oauth_cb': www.twitter.OAuthCB,
  'www/redirect': www.views.redirectParent,
  'www/morpho': www.views.morphotest,
}

