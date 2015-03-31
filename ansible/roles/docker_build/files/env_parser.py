#!/usr/bin/env python

import os
import ConfigParser

MAPPING = {
    '0': '/',
    '1': '-',
    '2': '_',
    '3': '.',
}

def parser(name, pos):
    """ Parse sections of an ENV variable name. An example ENV variable would
        be "YAODU_0_root_0_example_3_cnf_9_DEFAULT_9_setting_1_name"
        Using the mapping above, this name translates to:
        FILE: /root/example.cnf
              [DEFAULT]
              setting-name=${ENV_var_value}
    """
    var = str()

    for c, l in enumerate(name[pos:], start=pos):
        if l == '9':
            break
        elif l in MAPPING:
            var += MAPPING[l]
        else:
            var += l

    return var, c + 1

def main():
    configs = dict()

    for k, v in os.environ.items():
        name = k.split('_')
        if name[0] != os.getenv('PREFIX', 'YAODU'):
            continue

        filename, pos = parser(name, 1)
        section, pos = parser(name, pos)
        key, pos = parser(name, pos)

        if filename in configs:
            if section in configs[filename]:
                configs[filename][section][key] = v
            else:
                configs[filename][section] = {key: v}
        else:
            configs[filename] = {section: {key: v}}

    for filename, v in configs.items():
        config = ConfigParser.RawConfigParser()

        for section, w in v.items():
            for key, value in w.items():
                if section.upper() == "DEFAULT":
                    section = section.upper()
                else:
                    try:
                        config.add_section(section)
                    except ConfigParser.DuplicateSectionError:
                        pass

                config.set(section, key, value)

        with open(filename, 'wb') as configfile:
                config.write(configfile)

if __name__ == '__main__':
    main()
