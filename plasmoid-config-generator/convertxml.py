import argparse
import xml.etree.ElementTree as ET
import os

parser = argparse.ArgumentParser(
    description='Converts an existing xml to extras format to make converting to comment format faster',
    epilog='Written by Alexankitty 2023.',
    add_help=True)

parser.add_argument('filename', help='Filepath of your main config qml')
parser.add_argument('-o', '--output', help='Where to output the result', dest='output')

args = parser.parse_args()

filename = args.filename
output = args.output

filePath = os.path.abspath(filename)

if output:
    outputPath = os.path.abspath(output)
else:
    outputPath = os.getcwd() + "/extras.txt"

tree = ET.parse(filePath)
root = tree.getroot()

txtFile = ''
for child in root.iter("{http://www.kde.org/standards/kcfg/1.0}entry"):
    propName = child.get("name")
    propType = child.get("type")
    propLabel = child.find("{http://www.kde.org/standards/kcfg/1.0}label").text
    propDefault = child.find("{http://www.kde.org/standards/kcfg/1.0}default").text
    if not propDefault:
        propDefault = "''"
    propChoice = ""
    if propType == "Enum":
        for choice in child.iter("{http://www.kde.org/standards/kcfg/1.0}choice"):
            propChoice += choice.get("name") + " "
            print(choice.get("name"))
        propChoice = propChoice.strip()
        if propChoice:
            txtFile += f'cfg_{propName}: //type: {propType}; label: {propLabel}; enum: {propChoice}; default: {propDefault}\n'
        else:
            txtFile += f'cfg_{propName}: //type: {propType}; label: {propLabel}; default: {propDefault}\n'
    else:
        txtFile += f'cfg_{propName}: //type: {propType}; label: {propLabel}; default: {propDefault}\n'

with open(outputPath, 'w') as f:
    f.writelines(txtFile)
    f.close()
print(f'Wrote config file to {outputPath}.')