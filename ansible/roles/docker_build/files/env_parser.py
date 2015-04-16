#!/usr/bin/env python

import os
import ConfigParser

ESCAPE = '_'
EOL = '9' + ESCAPE

MAPPING = {
    '/': '0',
    '-': '1',
    '_': '2',
    '.': '3',
    ' ': '4',
}

REV_MAPPING = {v: k for k, v in MAPPING.items()}

def parser(name, pos):
    """ Parse sections of an ENV variable name. An example ENV variable would
        be "YAODU_root_0_example_3_cnf_9_DEFAULT_9_setting_1_name"
        Using the mapping above, this name translates to:
        FILE: /root/example.cnf
              [DEFAULT]
              setting-name=${ENV_var_value}
    """

    new_name = str()

    for c, l in enumerate(name[pos:], start=pos):
        if l == EOL[0] or l == '':
            break
        else:
            if l[0] in REV_MAPPING:
                new_name += REV_MAPPING[l[0]]
                new_name += l[1:]
            else:
                new_name += l

    return new_name, c + 1

def main():
    configs = dict()

    prefix = os.getenv('PREFIX', 'YAODU')

    for k, v in os.environ.items():
        name = k.split(ESCAPE)

        if name[0] != prefix:
            continue

        filename = None
        pos = 2
        while not filename:
            filename, pos = parser(name, pos)

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
