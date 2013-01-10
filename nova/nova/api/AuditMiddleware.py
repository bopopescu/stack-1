"""
operation audit middleware

"""
from nova.openstack.common import log as logging
from nova.openstack.common import local
from nova import wsgi
import time
import pdb

LOG = logging.getLogger('nova.api.audit')

class AuditMiddleware(wsgi.Middleware):
    def __init__(self, application, audit_methods='POST,PUT,DELETE'):
        wsgi.Middleware.__init__(self, application)
        self._audit_methods = audit_methods.split(",")

    def process_request(self, req):
        self._need_audit = req.method in self._audit_methods
        self._request = req
        self._requested_at = time.time()

    def process_response(self, response):  
        if self._need_audit:
            self._store_log(response)  
        return response  

    def _store_log(self, response):
        client_ip = self._request.headers.get('HOST')
        roles = self._request.headers.get('X-Roles')
        tenant = self._request.headers.get('X-Tenant-Name')
        user = self._request.headers.get('X-User-Name')
        request_time = self._requested_at
        path_info = self._request.path_info
        method = self._request.method
        body = self._request.body
        

        print locals()
        print "------------------------------------------------------"
        print "------------------------------------------------------"


