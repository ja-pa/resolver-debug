#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 16 17:54:49 2018

@author: cznic
"""



"""
opendns without dnssec validation - Primary, secondary DNS servers: 208.67.222.222 and 208.67.220.220

"""
import subprocess
import socket
from syslog import LOG_ERR, LOG_INFO, LOG_DEBUG, LOG_WARNING
import sys
import json
import pprint



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

def log():
    pass

def test_rootkey():
    pass


def test_date():

def set_dnssec(val):
    pass


def test_ping():
    pass


def test_dig(domain,resolver,dnssec=True):
    pass

def get_info():
    pass


def call_kresd(cmd,socket_path):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(2)
    try:
        sock.connect(socket_path)
        sock.sendall(cmd + "\n")
        ret = sock.recv(4096)
        sock.close()
        return ret
    except socket.error:#, msg:
        log("Kresd socket failed:%s,%s" % (socket.error, msg), LOG_ERR)
        sys.exit(1)

def conv_to_dict(text):
    return { i.split(":")[0]:i.split(":")[1] for i in text.split(",")}

class ResolverDebug:
    def __init__(self):
        pass
    def get_flags(self):
        pass


def parse_dig(raw):
    raw=raw.replace("\\t"," ")
    header=None
    flags=None
    answer_section=False
    authority_section=False
    answer_text=""
    authority_text=""
    for line in raw.split("\\n"):
        if line.find("->>HEADER<<-")>0:
            ccc=line.replace(" ","").replace(";;->>HEADER<<-","")
            header=conv_to_dict(ccc)

        if line.find("flags:")>0 and line.startswith(";;"):
            aa=line.replace(": ",":").replace(";; ","")
            aa=",".join(aa.split(";"))
            aa=aa.replace(", ",",")
            flags=conv_to_dict(aa)
            flag_list=flags["flags"].split(" ")
            flags["flags"]=flag_list

        if not line and answer_section==True:
            answer_section=False
        if not line and authority_section==True:
            authority_section=False

        if answer_section==True:
            answer_text+=answer_text+line+"\n"

        if authority_section==True:
            authority_text+=authority_text+line+"\n"

        if line.find("ANSWER SECTION:")>0:
            answer_section=True

        if line.find("AUTHORITY SECTION:")>0:
            authority_section=True

        if line.find("Query time:")>0:
            query_time=line.split(":")[1].replace(" ","")

        if line.find("SERVER:")>0:
            server=line.split(":")[1].replace(" ","")

    return {"header":header,
            "flags":flags,
            "answer":answer_text,
            "authority":authority_text,
            "query_time":query_time,
            "server":server}

def parse_ping(raw):
    lines=(raw.split("\\n"))
    stat_section=False
    stat=0
    status=None
    loss=100
    if raw=="b''":
        status="unknown"
    else:
        for line in lines:
            if stat_section==True:
                stat_section=False
                stat=line.split(",")
            if line.find("ping statistics ---")>0:
                stat_section=True
        loss=stat[2].replace(" ","").replace("%packetloss","")
        status="ok"
    return{"packet_loss":loss,"status":status}


bbb=str(call_cmd(["ping","-c 5","18.1.1.1","-w 5"]))

print(parse_ping(bbb))

aaa=str(call_cmd(["dig","@8.8.8.8","asdfsdf","+dnssec"]))
pp = pprint.PrettyPrinter(depth=6)
pp.pprint(parse_dig(aaa))

