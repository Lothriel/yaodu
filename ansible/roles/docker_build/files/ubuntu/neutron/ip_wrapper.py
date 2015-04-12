#!/usr/bin/env python

import sys
import subprocess
import nsenter

def host_mnt_exec(cmd):
    try:
        with nsenter.ExitStack() as stack:
            stack.enter_context(nsenter.Namespace('1', 'mnt', proc='/opt/yaodu/host_proc/'))
            process_ = subprocess.Popen(cmd)
    except IOError as exc:
        parser.error('Unable to access PID: {0}'.format(exc))
    except OSError as exc:
        parser.error('Unable to enter {0} namespace: {1}'.format(
            ns.ns_type, exc
        ))

    return process_

if len(sys.argv) > 2:
    if str(sys.argv[1]).startswith("net") and \
                (str(sys.argv[2]).startswith("a") or str(sys.argv[2]).startswith("d")):
        cmd = ["/usr/bin/env", "ip"] + sys.argv[1:]
        sys.exit(host_mnt_exec(cmd).returncode)
    else:
        cmd = ["/opt/yaodu/ip"] + sys.argv[1:]
else:
    cmd = ["/opt/yaodu/ip"]

    if len(sys.argv) == 2:
        cmd = cmd + sys.argv[1:]

process_ = subprocess.Popen(cmd)
sys.exit(process_.returncode)
