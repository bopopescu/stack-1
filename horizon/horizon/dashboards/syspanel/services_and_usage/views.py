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
from nova import context as nova_context
from cinder import context as cinder_context
import nova.flags as nova_flags
import cinder.flags as cinder_flags
from nova import db as nova_db
from cinder import db as cinder_db

from .services.tables import ServicesTable
from .usage.tables import UsageTable

LOG = logging.getLogger(__name__)


class IndexView(tables.MultiTableView):
    table_classes = (ServicesTable, UsageTable)
    template_name = 'syspanel/services_and_usage/index.html'

    def get_services_data(self):
        services = []

        ctxt = nova_context.get_admin_context()
        FLAGS = nova_flags.FLAGS
        nova_flags.parse_args([])
        db_nova_services=nova_db.service_get_all(ctxt)

        ctxt = cinder_context.get_admin_context()
        FLAGS=cinder_flags.FLAGS
        cinder_flags.parse_args([])
        db_cinder_services=cinder_db.service_get_all(ctxt)
        db_cinder_services.extend(db_nova_services)
        for i, service in enumerate(db_cinder_services):
            service['id'] = i
            services.append(service)

        services = sorted(services, key=lambda svc: (svc.host))#sort the list

        return services

    def get_usage_data(self):
        services = []
        ctxt = nova_context.get_admin_context()
        FLAGS = nova_flags.FLAGS
        nova_flags.parse_args([])
        db_compute_nodes=nova_db.compute_node_get_all(ctxt)
       
        for i, service in enumerate(db_compute_nodes):
            service['id'] = i
            service['mem'] = str(service['memory_mb_used'])+"/"+str(service['memory_mb'])
            service['disk'] = str(service['local_gb_used'])+"/"+str(service['local_gb'])
            service['cpu'] = str(service['vcpus_used'])+"/"+str(service['vcpus'])
            services.append(service)

        return services

