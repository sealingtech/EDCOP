from jinja2 import Environment, FileSystemLoader, Template, PackageLoader
import os
import sys

KICKSTART_SCRIPTS = ["network", "storage", "packages", "post-nochroot","post-chroot"]
 
def ksCreator(menuData):
    # Get path to templates
    #chDir = os.getcwd()
    os.chdir(sys.path[0])
    templatesKS = os.getcwd() + "/kickstarts/"
        
    env = Environment(loader= FileSystemLoader(templatesKS))
    # Loop over all KICKSTART_SCRIPTS defined templates to create fully populated .ks files
    for index in range(len(KICKSTART_SCRIPTS)):
        config_template = env.get_template(KICKSTART_SCRIPTS[index] + '.ks')
        config_rendered = config_template.render(data=menuData)
        fileName = "/tmp/ks/" + KICKSTART_SCRIPTS[index] + ".ks"
        outFile = open(fileName, "w")
        outFile.write(config_rendered)
        outFile.close()
    
    return
