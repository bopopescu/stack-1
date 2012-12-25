import logging

from django import template
from django.utils.translation import ugettext_lazy as _
from django.utils.safestring import mark_safe

from horizon import tables


LOG = logging.getLogger(__name__)


def get_stats(service):
    return template.loader.render_to_string('syspanel/services/_stats.html',
                                            {'service': service})


def get_enabled(service, reverse=False):
    options = ["Enabled", "Disabled"]
    if reverse:
        options.reverse()
    return options[0] if not service.disabled else options[1]

def get_smon(service):
    
    #url = "horizon:syspanel:images:update"
    return mark_safe("<a href='http://192.168.40.30/ganglia/graph.php?g=network_report&z=large&c=OpenStack&h=sdc-openstack-controller&m=load_one&r=hour&s=descending&hc=4&mc=2&st=1356406076'>detail</a>")

class UsageTable(tables.DataTable):
    id = tables.Column('id', verbose_name=_('Id'), hidden=True)
    host = tables.Column('hypervisor_hostname',verbose_name=_('Host'))
    cpu = tables.Column('cpu', verbose_name=_('CPU'))
    mem = tables.Column('mem', verbose_name=_('Memory(M)'))
    vms = tables.Column('running_vms', verbose_name=_('VMS'))
    disk = tables.Column('disk', verbose_name=_("Disk(G)"))
    smon = tables.Column(get_smon, 
                         verbose_name=_("System Monitor"))
      
    class Meta:
        name = "usage"
        verbose_name = _("Resource Usage")
        multi_select = False
