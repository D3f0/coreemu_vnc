#!/env/bin/python
# -*- coding: UTF-8 -*-

# import os
# import sys
# import cherrymusicserver
# import cherrypy

# from os.path import expandvars, dirname, abspath, join as joinpath
# from browsepy import app as browsepy, plugin_manager


# class HTTPHandler(cherrymusicserver.httphandler.HTTPHandler):
#     def autoLoginActive(self):
#         return True

# class Root(object):
#     pass

# cherrymusicserver.httphandler.HTTPHandler = HTTPHandler

# base_path = abspath(dirname(__file__))
# static_path = joinpath(base_path, 'static')
# media_path = expandvars('$HOME/media')
# download_path = joinpath(media_path, 'downloads')
# root_config = {
#     '/': {
#         'tools.staticdir.on': True,
#         'tools.staticdir.dir': static_path,
#         'tools.staticdir.index': 'index.html',
#     }
# }
# cherrymusic_config = {
#     'server.rootpath': '/player',
# }
# browsepy.config.update(
#     APPLICATION_ROOT = '/browse',
#     directory_base = media_path,
#     directory_start = media_path,
#     directory_remove = media_path,
#     directory_upload = media_path,
#     plugin_modules = ['player'],
# )
# plugin_manager.reload()

# if __name__ == '__main__':
#     sys.stderr = open(joinpath(base_path, 'stderr.log'), 'w')
#     sys.stdout = open(joinpath(base_path, 'stdout.log'), 'w')

#     with open(joinpath(base_path, 'pidfile.pid'), 'w') as f:
#         f.write('%d' % os.getpid())

#     cherrymusicserver.setup_config(cherrymusic_config)
#     cherrymusicserver.setup_services()
#     cherrymusicserver.migrate_databases()
#     cherrypy.tree.graft(browsepy, '/browse')
#     cherrypy.tree.mount(Root(), '/', config=root_config)

#     try:
#         cherrymusicserver.start_server(cherrymusic_config)
#     finally:
#         print('Exiting...')

from browsepy.__main__ import app, main

if __name__ == '__main__':
    app.config.update(
        APPLICATION_ROOT = '/browsepy/',
    )

    main(app=app)