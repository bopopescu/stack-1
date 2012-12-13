# vim: tabstop=4 shiftwidth=4 softtabstop=4

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
import random
from django import template
from django.core import urlresolvers
from django.template.defaultfilters import title
from django.utils.http import urlencode
from django.utils.translation import ugettext_lazy as _
from django.utils.safestring import mark_safe
import os

from horizon import api
from horizon import tables
from horizon.templatetags import sizeformat
from horizon.utils.filters import replace_underscores

from horizon.dashboards.nova.access_and_security \
        .floating_ips.workflows import IPAssociationWorkflow
from .tabs import InstanceDetailTabs, LogTab, VNCTab


LOG = logging.getLogger(__name__)

ACTIVE_STATES = ("ACTIVE",)

POWER_STATES = {
    0: "NO STATE",
    1: "RUNNING",
    2: "BLOCKED",
    3: "PAUSED",
    4: "SHUTDOWN",
    5: "SHUTOFF",
    6: "CRASHED",
    7: "SUSPENDED",
    8: "FAILED",
    9: "BUILDING",
}

PAUSE = 0
UNPAUSE = 1
SUSPEND = 0
RESUME = 1


def _is_deleting(instance):
    task_state = getattr(instance, "OS-EXT-STS:task_state", None)
    if not task_state:
        return False
    return task_state.lower() == "deleting"


class TerminateInstance(tables.BatchAction):
    name = "terminate"
    action_present = _("Terminate")
    action_past = _("Scheduled termination of")
    data_type_singular = _("Instance")
    data_type_plural = _("Instances")
    classes = ('btn-danger', 'btn-terminate')

    def allowed(self, request, instance=None):
        if instance:
            # FIXME(gabriel): This is true in Essex, but in FOLSOM an instance
            # can be terminated in any state. We should improve this error
            # handling when LP bug 1037241 is implemented.
            return instance.status not in ("PAUSED", "SUSPENDED")
        return True

    def action(self, request, obj_id):
        api.server_delete(request, obj_id)


class RebootInstance(tables.BatchAction):
    name = "reboot"
    action_present = _("Reboot")
    action_past = _("Rebooted")
    data_type_singular = _("Instance")
    data_type_plural = _("Instances")
    classes = ('btn-danger', 'btn-reboot')

    def allowed(self, request, instance=None):
        return ((instance.status in ACTIVE_STATES
                 or instance.status == 'SHUTOFF')
                and not _is_deleting(instance))

    def action(self, request, obj_id):
        api.server_reboot(request, obj_id)


class TogglePause(tables.BatchAction):
    name = "pause"
    action_present = (_("Pause"), _("Unpause"))
    action_past = (_("Paused"), _("Unpaused"))
    data_type_singular = _("Instance")
    data_type_plural = _("Instances")
    classes = ("btn-pause",)

    def allowed(self, request, instance=None):
        self.paused = False
        if not instance:
            return self.paused
        self.paused = instance.status == "PAUSED"
        if self.paused:
            self.current_present_action = UNPAUSE
        else:
            self.current_present_action = PAUSE
        return ((instance.status in ACTIVE_STATES or self.paused)
                and not _is_deleting(instance))

    def action(self, request, obj_id):
        if self.paused:
            api.server_unpause(request, obj_id)
            self.current_past_action = UNPAUSE
        else:
            api.server_pause(request, obj_id)
            self.current_past_action = PAUSE


class ToggleSuspend(tables.BatchAction):
    name = "suspend"
    action_present = (_("Suspend"), _("Resume"))
    action_past = (_("Suspended"), _("Resumed"))
    data_type_singular = _("Instance")
    data_type_plural = _("Instances")
    classes = ("btn-suspend",)

    def allowed(self, request, instance=None):
        self.suspended = False
        if not instance:
            self.suspended
        self.suspended = instance.status == "SUSPENDED"
        if self.suspended:
            self.current_present_action = RESUME
        else:
            self.current_present_action = SUSPEND
        return ((instance.status in ACTIVE_STATES or self.suspended)
                and not _is_deleting(instance))

    def action(self, request, obj_id):
        if self.suspended:
            api.server_resume(request, obj_id)
            self.current_past_action = RESUME
        else:
            api.server_suspend(request, obj_id)
            self.current_past_action = SUSPEND


class LaunchLink(tables.LinkAction):
    name = "launch"
    verbose_name = _("Launch Instance")
    url = "horizon:nova:instances:launch"
    classes = ("btn-launch", "ajax-modal")


class EditInstance(tables.LinkAction):
    name = "edit"
    verbose_name = _("Edit Instance")
    url = "horizon:nova:instances:update"
    classes = ("ajax-modal", "btn-edit")

    def allowed(self, request, instance):
        return not _is_deleting(instance)

class ConfirmResize(tables.LinkAction):
    name = 'confirm_resize'
    verbose_name = _("Confirm Resize")
    url = "horizon:nova:instances:confirmresize"
    classes = ('ajax-modal', "btn-associate")

    def allowed(self, request, instance=None):
        return instance.status in ('VERIFY_RESIZE',)


class Resize(tables.LinkAction):
    name = "resize"
    verbose_name = _("Resize Instance")
    url = "horizon:nova:instances:resize"
    classes = ("ajax-modal", "btn-associate")


    def allowed(self, request, instance=None):
        return instance.status in ACTIVE_STATES and not _is_deleting(instance)

    #def get_link_url(self, datum):
        #base_url = urlresolvers.reverse(self.url)
    #    next = urlresolvers.reverse("horizon:nova:instances:index")
        #params = {"instance_id": self.table.get_object_id(datum)}#,
                  #IPAssociationWorkflow.redirect_param_name: next}
        #params = urlencode(params)
    #    return self.url#"?".join([base_url, params])


class CreateSnapshot(tables.LinkAction):
    name = "snapshot"
    verbose_name = _("Create Snapshot")
    url = "horizon:nova:images_and_snapshots:snapshots:create"
    classes = ("ajax-modal", "btn-camera")

    def allowed(self, request, instance=None):
        return instance.status in ACTIVE_STATES and not _is_deleting(instance)


class ConsoleLink(tables.LinkAction):
    name = "console"
    verbose_name = _("VNC Console")
    url = "horizon:nova:instances:detail"
    classes = ("btn-console",)

    def allowed(self, request, instance=None):
        return instance.status in ACTIVE_STATES and not _is_deleting(instance) or instance.status in ('RESIZE', 'VERIFY_RESIZE')

    def get_link_url(self, datum):
        base_url = super(ConsoleLink, self).get_link_url(datum)
        tab_query_string = VNCTab(InstanceDetailTabs).get_query_string()
        return "?".join([base_url, tab_query_string])


class LogLink(tables.LinkAction):
    name = "log"
    verbose_name = _("View Log")
    url = "horizon:nova:instances:detail"
    classes = ("btn-log",)

    def allowed(self, request, instance=None):
        return instance.status in ACTIVE_STATES and not _is_deleting(instance)

    def get_link_url(self, datum):
        base_url = super(LogLink, self).get_link_url(datum)
        tab_query_string = LogTab(InstanceDetailTabs).get_query_string()
        return "?".join([base_url, tab_query_string])


class AssociateIP(tables.LinkAction):
    name = "associate"
    verbose_name = _("Associate Floating IP")
    url = "horizon:nova:access_and_security:floating_ips:associate"
    classes = ("ajax-modal", "btn-associate")

    def allowed(self, request, instance):
        return not _is_deleting(instance)

    def get_link_url(self, datum):
        base_url = urlresolvers.reverse(self.url)
        next = urlresolvers.reverse("horizon:nova:instances:index")
        params = {"instance_id": self.table.get_object_id(datum),
                  IPAssociationWorkflow.redirect_param_name: next}
        params = urlencode(params)
        return "?".join([base_url, params])


class UpdateRow(tables.Row):
    ajax = True

    def get_data(self, request, instance_id):
        instance = api.server_get(request, instance_id)
        instance.full_flavor = api.flavor_get(request, instance.flavor["id"])
        return instance


def get_ips(instance):
    template_name = 'nova/instances/_instance_ips.html'
    context = {"instance": instance}
    return template.loader.render_to_string(template_name, context)


def get_usage(instance):
    ret = "<div class='rsusage' value='" + instance.id + "' ><B>CPU: </B>--<br><B>MEM: </B>-------<br><B>NetIn: </B>--<br><B>NetOut: </B>--</div>"
    return mark_safe(ret)

def get_iname(instance):
    return instance.image_name

def get_instance_url(instance):
    #port = random.randint(10000, 60000) 
    #rule = "iptables -t nat -I PREROUTING -d 159.226.50.227/32 -p tcp -m tcp --dport %s -j DNAT --to-destination %s:22" % (str(port), instance.addresses['private'][0]['addr'])
    #os.popen(rule)
    #return "159.226.50.227:%s" % (str(port))
    if instance.id == "7f737ac1-03ed-4863-976c-55b3222baa89":
    	url= "159.226.50.227:%s" % (str(16390))
	return mark_safe("<a href= 'http://%s' target='blank'>%s</a>"%(url, url))
    elif instance.id == "12cae4d0-af8a-42cf-831b-cb6e47cc4817":
    	url = "159.226.50.227:%s" % (str(17391))
	return mark_safe("<a href= 'http://%s' target='blank'>%s</a>"%(url, url))
    elif instance.id == "b94620ef-cb4a-4bb4-bb8d-1e099c3c9e1c":
    	url = "159.226.50.227:%s" % (str(18910))
	return mark_safe("<a href= 'http://%s' target='blank'>%s</a>"%(url, url))
    return "--"

def get_size(instance):
    if hasattr(instance, "full_flavor"):
        size_string = _("%(name)s<br>%(RAM)s RAM<br>%(VCPU)s VCPU"
                        "<br>%(disk)s Disk")
        vals = {'name': instance.full_flavor.name,
                'RAM': sizeformat.mbformat(instance.full_flavor.ram),
                'VCPU': instance.full_flavor.vcpus,
                'disk': sizeformat.diskgbformat(instance.full_flavor.disk)}
        return mark_safe(size_string % vals)
    return _("Not available")


def get_keyname(instance):
    if hasattr(instance, "key_name"):
        keyname = instance.key_name
        return keyname
    return _("Not available")


def get_power_state(instance):
    return POWER_STATES.get(getattr(instance, "OS-EXT-STS:power_state", 0), '')


class InstancesTable(tables.DataTable):
    TASK_STATUS_CHOICES = (
        (None, True),
        ("none", True)
    )
    STATUS_CHOICES = (
        ("active", True),
        ("shutoff", True),
        ("suspended", True),
        ("paused", True),
        ("error", False),
    )
    TASK_DISPLAY_CHOICES = (
        ("image_snapshot", "Snapshotting"),
    )
    name = tables.Column("name",
                         link=("horizon:nova:instances:detail"),
                         verbose_name=_("Name"))
    ip = tables.Column(get_ips, verbose_name=_("IP Address"))
    size = tables.Column(get_size,
                         verbose_name=_("Size"),
                         attrs={'data-type': 'size'})
    iname = tables.Column(get_iname,
                          verbose_name=_("Image Name"))
    keypair = tables.Column(get_keyname, verbose_name=_("Keypair"))
    status = tables.Column("status",
                           filters=(title, replace_underscores),
                           verbose_name=_("Status"),
                           status=True,
                           status_choices=STATUS_CHOICES)
    task = tables.Column("OS-EXT-STS:task_state",
                         verbose_name=_("Task"),
                         filters=(title, replace_underscores),
                         status=True,
                         status_choices=TASK_STATUS_CHOICES,
                         display_choices=TASK_DISPLAY_CHOICES)
    state = tables.Column(get_power_state,
                          filters=(title, replace_underscores),
                          verbose_name=_("Power"))
    usage = tables.Column(get_usage,
                          verbose_name=_("Usage"))
#    instance_url = tables.Column(get_instance_url,
#    			  verbose_name=_('Instance URL'))
    

    class Meta:
        name = "instances"
        verbose_name = _("Instances")
        status_columns = ["status", "task"]
        row_class = UpdateRow
        table_actions = (LaunchLink, TerminateInstance)
        row_actions = (ConsoleLink, CreateSnapshot, Resize, ConfirmResize, AssociateIP, EditInstance,
                       LogLink, TogglePause, ToggleSuspend, RebootInstance,
                       TerminateInstance)
