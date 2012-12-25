import horizon
from horizon.dashboards.nova import dashboard


class Services(horizon.Panel):
    name = "Services"
    slug = 'services'


dashboard.Nova.register(Services)

