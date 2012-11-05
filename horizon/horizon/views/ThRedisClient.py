'''
Created on 2012-11-2

@author: Garven.Shen garvenshen@email.com
'''
import redis, inspect

class ThRedisClient(object):
    '''
    classdocs
    a redis client for thrift server to use.
    get information from openstack vm monitor db in redis.
    By default, each Redis instance you create will in turn create
its own connection pool.
    '''
    hostaddr='localhost'
    hostport=6379
    hostdb=0
    rs=None

    def __init__(self,redis_server=hostaddr, redis_port=hostport, redis_db=0):
        '''
        Constructor
        '''
        self.rs=redis.Redis(redis_server, redis_port, redis_db)
        
    def keys(self):
        return self.rs.keys('*')
    
    def getinstancekeys(self):
	return self.rs.keys('instance-*')

    def getuuidkeys(self):
	return self.rs.keys('uuid*')

    def getallbyinstance(self, instance_id):
        return self.rs.lrange(instance_id, 0,-1)

    def get1byinstance(self, instance_id, index):
        return self.rs.lindex(instance_id, index)

    def getrangebyinstance(self, instance_id, head, tail):
	#if head < 0 or head > self.rs.llen(instance_id):
	    #return 'head out of range in getrangebyinstance()!'
	#if tail < 0 or tail > self.rs.llen(instance_id):
	    #return 'tail out of range in getrangebyinstance()!'
	#else:
        return self.rs.lrange(instance_id, head, tail)

    def getuuid(self, instance_id_foruuid):
        return self.rs.get(instance_id_foruuid)

    def getlenbyinstance(self, instance_id):
        return self.rs.llen(instance_id)
    
if __name__ == '__main__':
    rediscli = ThRedisClient('localhost')
    instanceids = rediscli.getinstancekeys()
    print instanceids
    print ""
    for instanceid in instanceids:
	print rediscli.get1byinstance(instanceid, -1)
    
    
    
