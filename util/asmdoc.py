#!/usr/bin/python3
import os
import fnmatch
from jinja2 import Environment, PackageLoader, select_autoescape
import argparse

def get_filelist(directory, filespec):
    filelist = []
    for root, dir, files in os.walk(directory):
            for items in fnmatch.filter(files, filespec):
                    filelist.append("%s/%s" % (root, items))
    return (filelist)

def main():
    env = Environment(
        loader=PackageLoader("asmdoc"),
        autoescape=select_autoescape()
    )

    parser = argparse.ArgumentParser(
        prog='asmdoc',
        description='Generate documentation from annotated assembly source'
    )

    parser.add_argument('-d', '--directory', help="source path to scan", default=".")
    parser.add_argument('-f', '--file', help="output file", default="asmdoc.html")
    parser.add_argument('--filespec', help="filespec to search files", default="*.s")
    parser.add_argument('--format', help="output file format, html, md", default="html")


    args = parser.parse_args()

    params = []
    doc_struct = {}
    for filename in get_filelist(args.directory, args.filespec):
        with open(filename, "r") as f:
            for (ln, line) in enumerate(f):
                if not line.startswith(";@"):
                    continue

                tmp = line.strip().replace(";@", '').partition(':')

                if tmp[1] != ':':
                     print("Syntax error in %s:%d\n%s" % (filename, ln, line))
                params.append((tmp[0], tmp[2]))
                
                # print(line.split("@")[1].split(':'))
                # try:
                #     params.append(line.split("@")[1].split(':'))
                # except IndexError as e:
                #     print(e)

    # print (json.dumps(params))
    # return

    module = None
    proc_name = None
    for (name, value, filename, ln) in params:
        name = name.strip()
        value = value.strip().replace('"', '')

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
            doc_struct[module][proc_name] = {"git":"https://github.com/Steckschwein/code/tree/master/%s#L%d" % (filename, ln+1)}
            continue


        try:
            doc_struct[module][proc_name][name].append(value)
        except KeyError:
            doc_struct[module][proc_name][name] = [value]


    template = env.get_template("template.%s.j2" % args.format)

    with open(args.file, "w") as f:
        f.write(template.render(doc_struct=doc_struct))

    # print(json.dumps(doc_struct))
    # for module in doc_struct.keys():
    #     for proc_name in doc_struct[module].keys():

    #         print (module, proc_name)
    #         for par in doc_struct[module][proc_name].keys():
    #             print ("\t%s:\t\t%s" % (par, "; ".join(doc_struct[module][proc_name][par])))


if __name__ == "__main__":
     main()