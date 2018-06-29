from jinja2 import Environment, FileSystemLoader, Template, PackageLoader
import sys
import os

KICKSTART_OUTPUT_DIRECTORY = "/run/install/repo/ks/"

def master():
    # data for master node(s)
    kickstartScripts = ["main.ks", "network.ks", "storage.ks", "packages.ks", "post-nochroot.ks", "post-chroot.ks", "vars"]
    templateSubfoler = ""
    outDir = ""
    return kickstartScripts, templateSubfoler, outDir
    
def minion():
    # data for minion node(s)
    kickstartScripts = ["main.ks"]
    templateSubfoler = "minion"
    outDir = "minion/"
    return kickstartScripts, templateSubfoler, outDir


def kickstartGenerator(nodeType, menuData):
    # Get needed data for the requested node type
    kickstartScripts, templateSubfolder, outDir = nodeType()
    
    # Get templates
    os.chdir(sys.path[0])
    templatesKS = os.getcwd() + "/kickstarts/" + templateSubfolder
    
    if not os.path.exists(KICKSTART_OUTPUT_DIRECTORY + outDir):
        os.makedirs(KICKSTART_OUTPUT_DIRECTORY + outDir)
    
    env = Environment(loader= FileSystemLoader(templatesKS))
    
    # Loop over all KICKSTART_SCRIPTS defined templates to create fully populated .ks files
    for index in range(len(kickstartScripts)):
        config_template = env.get_template(kickstartScripts[index])
        config_rendered = config_template.render(data=menuData)
        fileName = KICKSTART_OUTPUT_DIRECTORY + outDir + kickstartScripts[index]
        outFile = open(fileName, "w")
        outFile.write(config_rendered)
        outFile.close()
    
    return
