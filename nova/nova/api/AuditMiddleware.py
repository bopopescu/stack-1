"""
operation audit middleware

"""

import webob.dec
import webob.exc

from nova import flags
from nova.openstack.common import cfg
from nova.openstack.common import log as logging
from nova import wsgi


#LOG = logging.getLogger(__name__)


#class AuditMiddleware(wsgi.Middleware):
#    def __init__(self, *args, **kwargs):
#        super(AuditMiddleware, self).__init__(*args, **kwargs)
#
#    @webob.dec.wsgify(RequestClass=wsgi.Request)
#    def __call__(self, req):
#        print req
#        return self.application

import time



LOG = logging.getLogger('nova.api.audit')

class AuditMiddleware(wsgi.Middleware):
    def __init__(self, application, audit_methods='POST,PUT,DELETE'):
        wsgi.Middleware.__init__(self, application)
        self._audit_methods = audit_methods.split(",")

    def process_request(self, req):
        self._need_audit = req.method in self._audit_methods
        if self._need_audit:
            self._request = req
            self._requested_at = time.time()
            self._store_log(response)

    def _store_log(self, response):
        client_ip = self._request.headers.get('HOST')
        request_time = self._requested_at
        

        req = self._request
        LOG.info("tenant: %s, user: %s, %s: %s, at: %s",
            req.headers.get('X-Tenant', 'admin'),
            req.headers.get('X-User', 'admin'),
            req.method,
            req.path_info,
            self._requested_at)


