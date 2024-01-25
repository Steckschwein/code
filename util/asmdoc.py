#!/usr/bin/python3
import os
import fnmatch
from jinja2 import Environment, PackageLoader, select_autoescape
import argparse


def main():
    env = Environment(
        loader=PackageLoader("asmdoc"),
        autoescape=select_autoescape()
    )

    parser = argparse.ArgumentParser(
        prog='asmdoc',
        description='Generate documentation from annotated assembly source'
    )
    
    parser.add_argument('-f', '--file', default="asmdoc.html")
    parser.add_argument('-d', '--directory', default=".")

    args = parser.parse_args()
    
    filelist = []
    for root, dir, files in os.walk(args.directory):
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
            proc_name = value.replace('"', '')
            doc_struct[module][proc_name] = {}
            continue

        try:
            doc_struct[module][proc_name][name].append(value)
        except KeyError:
            doc_struct[module][proc_name][name] = [value]
        
    

    template = env.get_template("template.html.j2")

    with open(args.file, "w") as f:
        f.write(template.render(
            modules=doc_struct.keys(),
            doc_struct=doc_struct
        ))
    # for module in doc_struct.keys():
    #     for proc_name in doc_struct[module].keys():

    #         print (module, proc_name)
    #         for par in doc_struct[module][proc_name].keys():
    #             print ("\t%s:\t\t%s" % (par, "; ".join(doc_struct[module][proc_name][par])))


if __name__ == "__main__":
     main()