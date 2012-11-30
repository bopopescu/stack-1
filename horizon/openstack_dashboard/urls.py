"""
URL patterns for the OpenStack Dashboard.
"""

from django.conf.urls.defaults import patterns, url, include
from django.conf.urls.static import static
from django.conf import settings
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

import horizon


urlpatterns = patterns('',
    url(r'^$', 'horizon.views.splash', name='splash'),
    url(r'^md/', 'horizon.views.get_md'),
    url(r'^freshcap/', 'horizon.views.freshcap'),
    url(r'^auth/', include('openstack_auth.urls')),
    url(r'', include(horizon.urls)),
    url(r'^captcha/', include('captcha.urls')),
    )
    

# Development static app and project media serving using the staticfiles app.
urlpatterns += staticfiles_urlpatterns()

# Convenience function for serving user-uploaded media during
# development. Only active if DEBUG==True and the URL prefix is a local
# path. Production media should NOT be served by Django.
#urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)


if settings.DEBUG is False:
    urlpatterns += patterns('',
        url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {
            'document_root': settings.STATIC_ROOT,
        }),
    )
