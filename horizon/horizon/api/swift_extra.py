# created by garvenshen
# email: shengeng@cnic.cn
# use for zeda-stack-swift

from horizon.api.swift import *

def swift_head_account(request, marker=None):
    headers = swift_api(request).get.head_account()
    bytes_used = headers['x-account-bytes-used']
    container_count = headers['x-account-container-count']
    object_count = headers['x-account-object-count']
    return {'bytes-used':bytes_used, 'container-count':container_count, 'object-count':object_count}


def swift_head_container(request, container_name):
    headers = swift_api(request).head_container(container_name)
    bytes_used = headers['x-container-bytes-used']
    object_count = headers['x-container-object-count']
    return {'bytes-used':bytes_used, 'object-count':object_count}


def swift_head_object(request, container_name, obj_name):
    headers = swift_api(request).head_object(container_name,obj_name)
    bytes_used = headers['content-length']
    origin_name = headers['x-object-meta-orig-filename']
    created_time = headers['date']
    last_modified = headers['last-modified']
    return {'bytes-used':bytes_used, 'origin_name':origin_name, 'created_time':created_time, 'last_modified':last_modified}

