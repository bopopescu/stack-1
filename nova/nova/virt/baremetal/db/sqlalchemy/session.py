# vim: tabstop=4 shiftwidth=4 softtabstop=4

# Copyright (c) 2012 NTT DOCOMO, INC.
# Copyright 2010 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
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

"""Session Handling for SQLAlchemy backend."""

from nova.db.sqlalchemy import session as nova_session
from nova.openstack.common import cfg

from eventlet import greenthread
from sqlalchemy.exc import DisconnectionError, OperationalError
import sqlalchemy.interfaces
import sqlalchemy.orm
from sqlalchemy.pool import NullPool, StaticPool

import nova.exception
from nova.openstack.common import cfg
import nova.openstack.common.log as logging

opts = [
    cfg.StrOpt('baremetal_sql_connection',
               default='sqlite:///$state_path/baremetal_$sqlite_db',
               help='The SQLAlchemy connection string used to connect to the '
                    'bare-metal database'),
    ]

CONF = cfg.CONF
CONF.register_opts(opts)

_ENGINE = None
_MAKER = None


def get_session(autocommit=True, expire_on_commit=False):
    """Return a SQLAlchemy session."""
    global _MAKER

    if _MAKER is None:
        engine = get_engine()
	_MAKER = get_maker(engine, autocommit, expire_on_commit)

    session = _MAKER()
    session = wrap_session(session)
    return session

def wrap_session(session):
    """Return a session whose exceptions are wrapped."""
    session.query = nova.exception.wrap_db_error(session.query)
    session.flush = nova.exception.wrap_db_error(session.flush)
    return session

def get_maker(engine, autocommit=True, expire_on_commit=False):
    """Return a SQLAlchemy sessionmaker using the given engine."""
    return sqlalchemy.orm.sessionmaker(bind=engine,
                                       autocommit=autocommit,
                                       expire_on_commit=expire_on_commit)

def get_engine():
    """Return a SQLAlchemy engine."""
    global _ENGINE
    if _ENGINE is None:
        _ENGINE = create_engine(CONF.baremetal_sql_connection)
    return _ENGINE


def create_engine(sql_connection):
    """Return a new SQLAlchemy engine."""
    connection_dict = sqlalchemy.engine.url.make_url(CONF.baremetal_sql_connection)

    engine_args = {
        "pool_recycle": CONF.sql_idle_timeout,
        "echo": False,
        'convert_unicode': True,
    }

    # Map our SQL debug level to SQLAlchemy's options
    if CONF.sql_connection_debug >= 100:
        engine_args['echo'] = 'debug'
    elif CONF.sql_connection_debug >= 50:
        engine_args['echo'] = True

    if "sqlite" in connection_dict.drivername:
        engine_args["poolclass"] = NullPool

        if CONF.baremetal_sql_connection == "sqlite://":
            engine_args["poolclass"] = StaticPool
            engine_args["connect_args"] = {'check_same_thread': False}

    engine = sqlalchemy.create_engine(sql_connection, **engine_args)

    if (CONF.sql_connection_trace and
            engine.dialect.dbapi.__name__ == 'MySQLdb'):
        import MySQLdb.cursors
        _do_query = debug_mysql_do_query()
        setattr(MySQLdb.cursors.BaseCursor, '_do_query', _do_query)

    try:
        engine.connect()
    except OperationalError, e:
        if not is_db_connection_error(e.args[0]):
            raise

        remaining = CONF.sql_max_retries
        if remaining == -1:
            remaining = 'infinite'
        while True:
            msg = _('SQL connection failed. %s attempts left.')
            LOG.warn(msg % remaining)
            if remaining != 'infinite':
                remaining -= 1
            time.sleep(CONF.sql_retry_interval)
            try:
                engine.connect()
                break
            except OperationalError, e:
                if (remaining != 'infinite' and remaining == 0) or \
                   not is_db_connection_error(e.args[0]):
                    raise
    return engine
