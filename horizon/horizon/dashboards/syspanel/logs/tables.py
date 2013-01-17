import logging

from django.utils.translation import ugettext_lazy as _

from horizon import tables


LOG = logging.getLogger(__name__)


class QuotaFilterAction(tables.FilterAction):
    def filter(self, table, tenants, filter_string):
        q = filter_string.lower()

        def comp(tenant):
            if q in tenant.name.lower():
                return True
            return False

        return filter(comp, tenants)


def get_quota_name(quota):
    return quota.name.replace("_", " ").title()


class QuotasTable(tables.DataTable):
    client_ip= tables.Column("client_ip", verbose_name=_('Client IP'))
    role = tables.Column('roles', verbose_name=_('Roles'))
    tenant = tables.Column('tenant', verbose_name=_('Tenant'))
    user = tables.Column('user', verbose_name=_('User'))
    time = tables.Column('created_at', verbose_name=_('time'))
    body = tables.Column('body', verbose_name=_('body'))
    method = tables.Column('method', verbose_name=_('method'))
    path_info= tables.Column('path_info', verbose_name=_('path'))

    class Meta:
        name = "quotas"
        verbose_name = _("Operation Log")
        table_actions = (QuotaFilterAction,)
        multi_select = False
