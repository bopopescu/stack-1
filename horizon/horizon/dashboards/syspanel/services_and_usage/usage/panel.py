import horizon
from horizon.dashboards.nova import dashboard


class Usage(horizon.Panel):
    name = "Usage"
    slug = 'usage'


dashboard.Nova.register(Usage)

