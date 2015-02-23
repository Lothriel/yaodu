#!py

def run():

    config = dict()

    config['pkgs'] = dict()

    if __grains__['os_family'] == 'Debian':
        config['pkgs']['docker'] = 'lxc-docker'
        config['pkgs']['pip'] = 'python-pip'

    return config
