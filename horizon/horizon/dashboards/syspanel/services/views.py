# vim: tabstop=4 shiftwidth=4 softtabstop=4

# Copyright 2012 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
#
# Copyright 2012 Nebula, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import logging

from horizon import api
from horizon import tables
from .tables import ServicesTable
from nova import context
import nova.flags as flags
from nova import db
from cinder import db as cinder_db
import cinder.flags as cinder_flags

#FLAGS = flags.FLAGS
#flags.parse_args([])
FLAGS=cinder_flags.FLAGS
cinder_flags.parse_args([])


LOG = logging.getLogger(__name__)


class IndexView(tables.DataTableView):
    table_class = ServicesTable
    template_name = 'syspanel/services/index.html'

    def get_data(self):
        ctxt = context.get_admin_context()
        db_services=db.service_get_all(ctxt)
        db_cinder_services=cinder_db.service_get_all(ctxt)

        services = []
        #for i, service in enumerate(self.request.user.service_catalog):
        for i, service in enumerate(db_services):
            service['id'] = i
            #services.append(api.keystone.Service(service))
            services.append(service)
        for i, service in enumerate(db_cinder_services):
            service['id'] = i
            #services.append(api.keystone.Service(service))
            services.append(service)
        return services
