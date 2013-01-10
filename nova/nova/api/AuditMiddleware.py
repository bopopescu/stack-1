"""
operation audit middleware

"""
from nova.openstack.common import log as logging
from nova.openstack.common import local
from nova import wsgi
from nova import db
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
        self.context = getattr(local.store, 'context', None)

    def process_response(self, response):  
        if self._need_audit:
            self._store_log(response)  
        return response  

    def _store_log(self, response):
        value = {}
        value["client_ip"] = self._request.headers.get('HOST')
        value["roles"] = self._request.headers.get('X-Roles')
        value["tenant"] = self._request.headers.get('X-Tenant-Name')
        value["user"] = self._request.headers.get('X-User-Name')
        value["time_at"] = self._requested_at
        value["path_info"] = self._request.path_info
        value["method"] = self._request.method
        value["body"] = self._request.body
        db.operation_log_create(self.context, value)



