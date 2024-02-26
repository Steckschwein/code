#!/usr/bin/python3
import os
import fnmatch
import re
from jinja2 import Environment, PackageLoader, select_autoescape
import argparse

def get_filelist(directory, filespec):
    filelist = []
    for root, dir, files in os.walk(directory):
            for items in fnmatch.filter(files, filespec):
                    filelist.append("%s/%s" % (root, items))
    return (filelist)

def render_template(filename, format, title, doc_struct):
    env = Environment(
        loader=PackageLoader("asmdoc"),
        autoescape=select_autoescape()
    )

    template = env.get_template("template.%s.j2" % format)

    with open(filename, "w") as f:
        f.write(template.render(doc_struct=doc_struct, title=title))

def main():

    parser = argparse.ArgumentParser(
        prog='asmdoc',
        description='Generate documentation from annotated assembly source'
    )

    parser.add_argument('-d', '--directory', help="source path to scan", default=".")
    parser.add_argument('-f', '--file', help="output file", default="asmdoc.html")
    parser.add_argument('--filespec', help="filespec to search files", default="*.s")
    parser.add_argument('--format', help="output file format, html, md", default="html")
    parser.add_argument('--title', help="document title", default="No Title")
    


    args = parser.parse_args()

    doc_struct = {  }
    regex = re.compile(";[\s]?@([a-z]+):?(.*)")

    for filename in get_filelist(args.directory, args.filespec):
        with open(filename, "r") as f:
            for (ln, line) in enumerate(f):
                m = regex.findall(line.strip())
                if not m:
                    continue

                m = m.pop()
            
                name = m[0].strip()
                value = m[1].strip().replace('"', '')
                  
                if name == 'module':
                    module_name = value
                    try:
                        if doc_struct[module_name]:
                            continue
                    except KeyError:
                            doc_struct[module_name] = {}
                    continue
                    
                if name == 'name':
                    proc_name = value
                    doc_struct[module_name][proc_name] = {
                        "filename": filename,
                        "line": ln+1            
                    }
                    continue

                
                try:
                    doc_struct[module_name][proc_name][name].append(value)
                except KeyError:
                    doc_struct[module_name][proc_name][name] = [value]

    render_template(args.file, args.format, args.title, doc_struct)

if __name__ == "__main__":
     main()