#!/usr/bin/python3
import json
import os
import sys
import fnmatch

filelist = []
for root, dir, files in os.walk("../steckos/libsrc/"):
        for items in fnmatch.filter(files, "*.s"):
                filelist.append("%s/%s" % (root, items))
       

params = []
doc_struct = {}
for filename in filelist:
    with open(filename, "r") as f:
        for line in f:
            if not line.startswith(";@"):
                continue

            line = line.strip()
            try:
                params.append(line.split("@")[1].split(':'))
            except IndexError as e:
                print(e)
module = None
proc_name = None   
for (name, value) in params:
    name = name.strip()
    value = value.strip()

    if name == 'module':
        module = value
        try:
            if not doc_struct[module]:
                doc_struct[module] = {}
        except KeyError:
                doc_struct[module] = {}
        continue
    if name == 'name':
        proc_name = value
        doc_struct[module][proc_name] = {}
        continue

    try:
        doc_struct[module][proc_name][name].append(value)
    except KeyError:
        doc_struct[module][proc_name][name] = [value]
      
   

for module in doc_struct.keys():
    for proc_name in doc_struct[module].keys():

        print (module, proc_name)
        for par in doc_struct[module][proc_name].keys():
            print ("\t%s:\t\t%s" % (par, "; ".join(doc_struct[module][proc_name][par])))
