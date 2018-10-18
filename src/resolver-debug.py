#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 16 17:54:49 2018

@author: cznic
"""
import subprocess
import socket
from syslog import LOG_ERR, LOG_INFO, LOG_DEBUG, LOG_WARNING
import sys
import json
import pprint
import syslog


"""
opendns without dnssec validation - Primary, secondary DNS servers: 208.67.222.222 and 208.67.220.220

"""


def log():
    pass


def call_cmd(cmd):
    assert isinstance(cmd, list)
    task = subprocess.Popen(cmd, shell=False, stdout=subprocess.PIPE)
    data = task.stdout.read()
    return data


def uci_get(path):
    return call_cmd(["uci", "get", "%s" % path]).rstrip()


def uci_get_bool(path, default):
    ret = uci_get(path)
    if ret in ('1', 'on', 'true', 'yes', 'enabled'):
        return True
    elif ret in ('0', 'off', 'false', 'no', 'disabled'):
        return False
    else:
        return default


def uci_set(path, val):
    return call_cmd(["uci", "set", "%s=%s" % (path, val)])


def conv_to_dict(text):
    return {i.split(":")[0]: i.split(":")[1] for i in text.split(",")}


def test_rootkey():
    pass


def test_date():
    pass


def set_dnssec(val):
    pass


class ResolverDebug:
    def __init__(self):
        pass

    def parse_dig(self, raw):
        raw = raw.replace("\\t", " ")
        header = None
        flags = None
        answer_section = False
        authority_section = False
        answer_text = ""
        authority_text = ""
        for line in raw.split("\\n"):
            if line.find("->>HEADER<<-") > 0:
                ccc = line.replace(" ", "").replace(";;->>HEADER<<-", "")
                header = conv_to_dict(ccc)

            if line.find("flags:") > 0 and line.startswith(";;"):
                aa = line.replace(": ", ":").replace(";; ", "")
                aa = ",".join(aa.split(";"))
                aa = aa.replace(", ", ",")
                flags = conv_to_dict(aa)
                flag_list = flags["flags"].split(" ")
                flags["flags"] = flag_list

            if not line and answer_section is True:
                answer_section = False

            if not line and authority_section is True:
                authority_section = False

            if answer_section is True:
                answer_text += answer_text+line+"\n"

            if authority_section is True:
                authority_text += authority_text+line+"\n"

            if line.find("ANSWER SECTION:") > 0:
                answer_section = True

            if line.find("AUTHORITY SECTION:") > 0:
                authority_section = True

            if line.find("Query time:") > 0:
                query_time = line.split(":")[1].replace(" ", "")

            if line.find("SERVER:") > 0:
                server = line.split(":")[1].replace(" ", "")

        return {"header": header,
                "flags": flags,
                "answer": answer_text,
                "authority": authority_text,
                "query_time": query_time,
                "server": server}

    def parse_ping(self, raw):
        lines = (raw.split("\\n"))
        stat_section = False
        stat = 0
        status = None
        loss = 100
        if raw == "b''":
            status = "unknown"
        else:
            for line in lines:
                if stat_section is True:
                    stat_section = False
                    stat = line.split(",")
                if line.find("ping statistics ---") > 0:
                    stat_section = True
            loss = int(stat[2].replace(" ", "").replace("%packetloss", ""))
            status = "ok"
        return{"packet_loss": loss, "status": status}

    def test_ping(self, address):
        out_cmd = str(call_cmd(["ping", "-c 5", address, "-w 5"]))
        resp = self.parse_ping(out_cmd)
        print(resp)
        if resp["packet_loss"] != 100 and resp["status"] == "ok":
            return True
        else:
            return False

    def test_dig(self, domain, resolver, dnssec=True, log=False):
        cmd_args = ["dig", "@"+resolver, domain]
        if dnssec is True:
            cmd_args.append("+dnssec")
        out_cmd = str(call_cmd(cmd_args))
        resp = self.parse_dig(out_cmd)
        if resp["header"]["status"] == "NOERROR":
            return True
        else:
            return False

    def call_kresd(self, cmd, socket_path):
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(2)
        try:
            sock.connect(socket_path)
            sock.sendall(cmd + "\n")
            ret = sock.recv(4096)
            sock.close()
            return ret
        except(socket.error):
            log("Kresd socket failed:%s,%s" % (socket.error), LOG_ERR)
            sys.exit(1)


"""
SERVFAIL
NXDOMAIN
NOERROR
"""

"""
resolver="8.8.8.8"
print("aaaaaaaaaaaaaaaaaaaaaaaa")
print(test_dig("www.idnes.cz",resolver,True))
print(test_dig("www.idnes.cz",resolver,True))

print(test_dig("api.turris.cz",resolver,True))             # should pass
print(test_dig("www.google.com",resolver,True))            # should pass
print(test_dig("www.youtube.com",resolver,True))           # should pass
print(test_dig("www.facebook.com",resolver,True))          # should pass
print(test_dig("*.wilda.nsec.0skar.cz",resolver,True))     # should pass
print(test_dig("www.wilda.nsec.0skar.cz",resolver,True))   # should pass
print(test_dig("www.wilda.0skar.cz",resolver,True))        # should pass
print(test_dig("*.wilda.0skar.cz",resolver,True))          # should pass
print(test_dig("*.wild.0skar.cz",resolver,True))           # should pass
print(test_dig("*.wild.nsec.0skar.cz",resolver,True))      # should pass

print(test_dig("*.wilda.rhybar.ecdsa.0skar.cz",resolver,True))  # should fail
print(test_dig("*.wilda.rhybar.0skar.cz",resolver,True))   # should fail
print(test_dig("www.rhybar.cz ",resolver,True))            # should fail
"""


if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "list":
            print(json.dumps({"aaa": {}}))
        elif sys.argv[1] == "call":
            print("Print call")
        else:
            syslog.syslog("Unknown argument.")
