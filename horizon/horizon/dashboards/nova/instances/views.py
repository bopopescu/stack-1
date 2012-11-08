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

"""
Views for managing Nova instances.
"""
import logging
import pdb
import random

from django import http
from django import shortcuts
from django.core.urlresolvers import reverse, reverse_lazy
from django.utils.datastructures import SortedDict
from django.utils.translation import ugettext_lazy as _

from horizon import api
from horizon import exceptions
from horizon import forms
from horizon import tabs
from horizon import tables
from horizon import workflows
from .forms import UpdateInstance
from .tabs import InstanceDetailTabs
from .tables import InstancesTable
from .workflows import LaunchInstance
from .workflows import InstanceResize
from .workflows import ConfirmInstanceResize


LOG = logging.getLogger(__name__)


class IndexView(tables.DataTableView):
    table_class = InstancesTable
    template_name = 'nova/instances/index.html'

    def get_data(self):
        # Gather our instances
        try:
            instances = api.server_list(self.request)
        except:
            instances = []
            exceptions.handle(self.request,
                              _('Unable to retrieve instances.'))
        # Gather our flavors and correlate our instances to them
        if instances:
            try:
                flavors = api.flavor_list(self.request)
            except:
                flavors = []
                exceptions.handle(self.request, ignore=True)

            full_flavors = SortedDict([(str(flavor.id), flavor)
                                        for flavor in flavors])
            # Loop through instances to get flavor info.
            for instance in instances:
                try:
                    flavor_id = instance.flavor["id"]
                    if flavor_id in full_flavors:
                        instance.full_flavor = full_flavors[flavor_id]
                    else:
                        # If the flavor_id is not in full_flavors list,
                        # get it via nova api.
                        instance.full_flavor = api.flavor_get(self.request,
                                                              flavor_id)
                except:
                    msg = _('Unable to retrieve instance size information.')
                    exceptions.handle(self.request, msg)
        return instances


class LaunchInstanceView(workflows.WorkflowView):
    workflow_class = LaunchInstance
    template_name = "nova/instances/launch.html"

    def get_initial(self):
        initial = super(LaunchInstanceView, self).get_initial()
        initial['project_id'] = self.request.user.tenant_id
        initial['user_id'] = self.request.user.id
        return initial


def console(request, instance_id):
    try:
        # TODO(jakedahn): clean this up once the api supports tailing.
        tail = request.GET.get('length', None)
        data = api.server_console_output(request,
                                        instance_id,
                                        tail_length=tail)
    except:
        data = _('Unable to get log for instance "%s".') % instance_id
        exceptions.handle(request, ignore=True)
    response = http.HttpResponse(mimetype='text/plain')
    response.write(data)
    response.flush()
    return response


def vnc(request, instance_id):
    try:
        console = api.server_vnc_console(request, instance_id)
        instance = api.server_get(request, instance_id)
        return shortcuts.redirect(console.url +
                ("&title=%s(%s)" % (instance.name, instance_id)))
    except:
        redirect = reverse("horizon:nova:instances:index")
        msg = _('Unable to get VNC console for instance "%s".') % instance_id
        exceptions.handle(request, msg, redirect=redirect)


class UpdateView(forms.ModalFormView):
    form_class = UpdateInstance
    template_name = 'nova/instances/update.html'
    context_object_name = 'instance'
    success_url = reverse_lazy("horizon:nova:instances:index")

    def get_context_data(self, **kwargs):
        context = super(UpdateView, self).get_context_data(**kwargs)
        context["instance_id"] = self.kwargs['instance_id']
        return context

    def get_object(self, *args, **kwargs):
        if not hasattr(self, "_object"):
            instance_id = self.kwargs['instance_id']
            try:
                self._object = api.server_get(self.request, instance_id)
            except:
                redirect = reverse("horizon:nova:instances:index")
                msg = _('Unable to retrieve instance details.')
                exceptions.handle(self.request, msg, redirect=redirect)
        return self._object

    def get_initial(self):
        return {'instance': self.kwargs['instance_id'],
                'tenant_id': self.request.user.tenant_id,
                'name': getattr(self.get_object(), 'name', '')}

class ConfirmResizeView(workflows.WorkflowView):
    workflow_class = ConfirmInstanceResize
    template_name = 'nova/instances/confirmresize.html'

class ResizeView(workflows.WorkflowView):
    workflow_class = InstanceResize
    template_name = 'nova/instances/resize.html'
    #context_object_name = 'instance'
    #success_url = reverse_lazy("horizon:nova:instances:index")

#    def get_context_data(self, **kwargs):
#        context = super(ResizeView, self).get_context_data(**kwargs)
#        context["instance_id"] = self.kwargs['instance_id']
#        return context
#
#    def get_object(self, *args, **kwargs):
#        if not hasattr(self, "_object"):
#            instance_id = self.kwargs['instance_id']
#            try:
#                self._object = api.server_get(self.request, instance_id)
#            except:
#                redirect = reverse("horizon:nova:instances:index")
#                msg = _('Unable to retrieve instance details.')
#                exceptions.handle(self.request, msg, redirect=redirect)
#        return self._object
#
#    def get_initial(self):
#        return {'instance': self.kwargs['instance_id'],
#                'tenant_id': self.request.user.tenant_id,
#                'name': getattr(self.get_object(), 'name', '')}

class DetailView(tabs.TabView):
    tab_group_class = InstanceDetailTabs
    template_name = 'nova/instances/detail.html'

    def get_context_data(self, **kwargs):
        context = super(DetailView, self).get_context_data(**kwargs)
        context["instance"] = self.get_data()
        return context

    def get_data(self):
        if not hasattr(self, "_instance"):
            try:
                instance_id = self.kwargs['instance_id']
                instance = api.server_get(self.request, instance_id)
                instance.volumes = api.volume_instance_list(self.request,
                                                            instance_id)
                # Sort by device name
                instance.volumes.sort(key=lambda vol: vol.device)
                instance.full_flavor = api.flavor_get(self.request,
                                                      instance.flavor["id"])
                instance.security_groups = api.server_security_groups(
                                           self.request, instance_id)
            except:
                redirect = reverse('horizon:nova:instances:index')
                exceptions.handle(self.request,
                                  _('Unable to retrieve details for '
                                    'instance "%s".') % instance_id,
                                    redirect=redirect)
            self._instance = instance
        return self._instance

    def get_tabs(self, request, *args, **kwargs):
        instance = self.get_data()
        return self.tab_group_class(request, instance=instance, **kwargs)
