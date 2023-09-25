import argparse
import re
import os

class Config(object):
    def __setitem__(self, key, value):
        setattr(self, key, value)

    def __getitem__(self, key):
        return getattr(self, key)

parser = argparse.ArgumentParser(
    description='Applies the contents of a converted file to a qml',
    epilog='Written by Alexankitty 2023.',
    add_help=True)

parser.add_argument('filename', help='Filepath of your main config qml')
parser.add_argument('input', help='Input file to append comments from')
parser.add_argument('-m', '--main-directory', help='Path to the main QML files', dest='mainDirectory')
parser.add_argument('-s', '--single-file',action='store_true', help='Disables file recursion and assumes one file only', dest='singleFile')

args = parser.parse_args()

filename = args.filename
singleFile = args.singleFile
inputFile = args.input
mainDirectory = args.mainDirectory

files = [None] * 0
if not singleFile:
    with open(filename, "r") as f:
        lines = f.readlines()
    for line in lines:
        if('source' in line):
            files.append(re.findall(r'"(.*?)"', line)[0])
    f.close()
else:
    files.append(filename)

if mainDirectory:
    workingDir = os.path.abspath(mainDirectory)
else:
    workingDir = os.path.dirname(os.path.abspath(filename))

inputFile = os.path.abspath(inputFile)

configEntries = [None] * 0

with open(inputFile, "r") as f:
    lines = f.readlines()
for line in lines:
    if("cfg_" in line):
        configEntry = Config()
        configEntry["name"] = re.findall(r'(?<=cfg_)\w+?(?=:|\s|$)', line)[0]
        config = re.findall(r'(?<=\/\/).*', line)[0]
        configEntry["value"] = f' //{config}'
        configEntries.append(configEntry)

for file in files:
    path = workingDir + "/" + file
    with open(path, "r") as f:
        lines = f.readlines()
        f.close()
    for index, line in enumerate(lines):
        if("cfg_" in line and "property" in line):
            name = re.findall(r'(?<=cfg_)\w+?(?=:|\s|$)', line)[0]
            for entry in configEntries:
                if name == entry.name:
                    lines[index] = lines[index].rstrip() + entry.value + "\n"
                    configEntries.remove(entry)
    with open(path, "w") as f:
        f.writelines(lines)
        f.close
        print(f'Wrote comments to {path}.')

path = workingDir + "/leftovers.txt"
with open(path, "w") as f:
    for entry in configEntries:
        f.write(f'cfg_{entry.name}: //{entry.value}\n')
        f.close
        print(f'Leftovers were written to {path}.')
