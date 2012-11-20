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

from django import shortcuts
from django.views import generic
from django.views.decorators import vary
from django.http import HttpResponse
from django.utils import simplejson
from ThRedisClient import *
from captcha.fields import CaptchaField
from django.utils.translation import ugettext as _
import string, time, datetime


from openstack_auth.views import Login

import horizon
from horizon import exceptions


def user_home(request):
    """ Reversible named view to direct a user to the appropriate homepage. """
    return shortcuts.redirect(horizon.get_user_home(request.user))


def get_user_home(user):
    if user.is_superuser:
        return horizon.get_dashboard('syspanel').get_absolute_url()
    return horizon.get_dashboard('nova').get_absolute_url()


@vary.vary_on_cookie
def splash(request):
    if request.user.is_authenticated():
        return shortcuts.redirect(get_user_home(request.user))
    
    #Login.base_fields['captcha'] = CaptchaField(help_text=_("CAPTCHA PLEASE"), error_messages=dict(invalid=_("CAPTCHA ERROR")))
    form = Login(request)

    if form.is_valid():
        human = True
    request.session.clear()
    request.session.set_test_cookie()
    # modified by shengeng for zeda
    #return shortcuts.render(request, 'splash.html', {'form': form})
    return shortcuts.render(request, 'auth/login.html', {'form': form})

def get_md(request):
    def total_IO(s):
        total = 0
	list_by_sharp = s.split('#')
	for l in list_by_sharp:
	    v = string.atof(l.split(':')[1])
            total = total + v
        return total
    result = {}
    rediscli = ThRedisClient('localhost')
    qin = request.GET['query'].split(',')
    tstart = request.GET['stime']
    
    if tstart == 'latest':
	for id in qin:
		temp = {}
		try:
			iinfo = rediscli.get1byinstance(id, -1).split('$')
			temp['cpu'] = iinfo[0]+"%"
			mem_usage = round((string.atof(iinfo[2])-string.atof(iinfo[1]))/string.atof(iinfo[2])*100, 2)
			temp['mem'] = mem_usage if mem_usage <= 100 else 100
			temp['netin'] = string.atoi(iinfo[3].split(':')[1])/1024/1024
			temp['netout'] = string.atoi(iinfo[4].split(':')[1])/1024/1024
			result[id] = temp
		except Exception,e:
			result[id] = None
    else:
	for id in qin:
		result[id+"-cpu"] = []
		result[id+"-mem"] = []
		result[id+"-NetIn"] = []
		result[id+"-NetOut"] = []
		result[id+"-DiskRead"] = []
		result[id+"-DiskWrite"] = []
		iinfos = rediscli.getrangebyinstance(id, -100, -1)
		#iinfos = rediscli.getallbyinstance(id)
		amcharts_item_cpu = {}
		amcharts_item_mem = {}
		amcharts_item_NetIn = {}
		amcharts_item_NetOut = {}
		amcharts_item_DiskRead = {}
		amcharts_item_DiskWrite = {}
		for s in iinfos:
			schips = s.split('$')
			date_obj =str( datetime.datetime.fromtimestamp(string.atoi(schips[-1])))
			cpu = schips[0]
                        mem = round((string.atof(schips[2]) - string.atof(schips[1]))/string.atof(schips[1])*100, 2)
                        NetIn = round(total_IO(schips[3])/1024/102,2)
                        NetOut = round(total_IO(schips[4])/1024/1024,2)
                        DiskRead = round(total_IO(schips[5])/1024/1024,2)
                        DiskWrite = round(total_IO(schips[6])/1024/1024,2)
			
			amcharts_item_cpu = {'date':date_obj, 'value':string.atof(cpu)}
			amcharts_item_mem = {'date':date_obj, 'value':string.atof(mem)}
			amcharts_item_NetIn = {'date':date_obj, 'value':string.atof(NetIn)}
			amcharts_item_NetOut = {'date':date_obj, 'value':string.atof(NetOut)}
			amcharts_item_DiskRead = {'date':date_obj, 'value':string.atof(DiskRead)}
			amcharts_item_DiskWrite = {'date':date_obj, 'value':string.atof(DiskWrite)}
			result[id+"-cpu"].append(amcharts_item_cpu)
			result[id+"-mem"].append(amcharts_item_mem)
			result[id+"-NetIn"].append(amcharts_item_NetIn)
			result[id+"-NetOut"].append(amcharts_item_NetOut)
			result[id+"-DiskRead"].append(amcharts_item_DiskRead)
			result[id+"-DiskWrite"].append(amcharts_item_DiskWrite)

    return HttpResponse(simplejson.dumps(result))


class APIView(generic.TemplateView):
    """ A quick class-based view for putting API data into a template.

    Subclasses must define one method, ``get_data``, and a template name
    via the ``template_name`` attribute on the class.

    Errors within the ``get_data`` function are automatically caught by
    the :func:`horizon.exceptions.handle` error handler if not otherwise
    caught.
    """
    def get_data(self, request, context, *args, **kwargs):
        """
        This method should handle any necessary API calls, update the
        context object, and return the context object at the end.
        """
        raise NotImplementedError("You must define a get_data method "
                                   "on %s" % self.__class__.__name__)

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        try:
            context = self.get_data(request, context, *args, **kwargs)
        except:
            exceptions.handle(request)
        return self.render_to_response(context)
