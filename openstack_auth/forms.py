import sys
import os
from django import forms
from django.conf import settings
from django.contrib.auth import authenticate
from django.contrib.auth.forms import AuthenticationForm
from django.utils.translation import ugettext as _
from django.views.decorators.debug import sensitive_variables

from .exceptions import KeystoneAuthException
sys.path.insert(0, os.path.join(os.path.dirname(os.path.realpath(__file__)), '../django_simple_captcha-0.3.0-py2.7.egg'))
from captcha.fields import CaptchaField

class Login(AuthenticationForm):
    region = forms.ChoiceField(label=_("Region"), required=False)
    username = forms.CharField(label=_("User Name"))
    password = forms.CharField(label=_("Password"),
                               widget=forms.PasswordInput(render_value=False))
    
    captcha = CaptchaField(label=_("Captcha"))
    
    tenant = forms.CharField(required=False, widget=forms.HiddenInput())

    def __init__(self, *args, **kwargs):
        super(Login, self).__init__(*args, **kwargs)
        self.fields['region'].choices = self.get_region_choices()
        if len(self.fields['region'].choices) == 1:
            self.fields['region'].initial = self.fields['region'].choices[0][0]
            self.fields['region'].widget = forms.widgets.HiddenInput()

    @staticmethod
    def get_region_choices():
        default_region = (settings.OPENSTACK_KEYSTONE_URL, "Default Region")
        return getattr(settings, 'AVAILABLE_REGIONS', [default_region])

    @sensitive_variables()
    def clean(self):
        username = self.cleaned_data.get('username')
        password = self.cleaned_data.get('password')
        region = self.cleaned_data.get('region')
        tenant = self.cleaned_data.get('tenant')

        if not tenant:
            tenant = None

        if not (username and password):
            # Don't authenticate, just let the other validators handle it.
            return self.cleaned_data

        try:
            self.user_cache = authenticate(request=self.request,
                                           username=username,
                                           password=password,
                                           tenant=tenant,
                                           auth_url=region)
        except KeystoneAuthException as exc:
            self.request.session.flush()
            raise forms.ValidationError(exc)
        self.check_for_test_cookie()
        return self.cleaned_data

