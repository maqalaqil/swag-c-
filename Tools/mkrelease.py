#!/usr/bin/env python

# This script builds the alaqil source tarball, creates the Windows executable and the Windows zip package
# and uploads them both to SF ready for release. Also uploaded are the release notes.
import sys
import string
import os

def failed(message):
  if message == "":
    print "mkrelease.py failed to complete"
  else:
    print message
  sys.exit(2)

try:
   version = sys.argv[1]
   branch = sys.argv[2]
   username = sys.argv[3]
except:
   print "Usage: python mkrelease.py version branch username"
   print "where version should be x.y.z and username is your SF username"
   sys.exit(1)

print "Looking for rsync"
os.system("which rsync") and failed("rsync not installed/found. Please install.")

print "Making source tarball"
os.system("python ./mkdist.py " + version + " " + branch) and failed("")

print "Build Windows package"
os.system("./mkwindows.sh " + version) and failed("")

print "Uploading to SourceForge"

alaqil_dir_sf = username + ",alaqil@frs.sourceforge.net:/home/frs/project/s/sw/alaqil/alaqil/alaqil-" + version + "/"
alaqilwin_dir_sf = username + ",alaqil@frs.sourceforge.net:/home/frs/project/s/sw/alaqil/alaqilwin/alaqilwin-" + version + "/"

# If a file with 'readme' in the name exists in the same folder as the zip/tarball, it gets automatically displayed as the release notes by SF
full_readme_file = "readme-" + version + ".txt"
os.system("rm -f " + full_readme_file)
os.system("cat alaqil-" + version + "/README " + "alaqil-" + version + "/CHANGES.current " + "alaqil-" + version + "/RELEASENOTES " + "> " + full_readme_file)

os.system("rsync --archive --verbose -P --times -e ssh " + "alaqil-" + version + ".tar.gz " + full_readme_file + " " + alaqil_dir_sf) and failed("")
os.system("rsync --archive --verbose -P --times -e ssh " + "alaqilwin-" + version + ".zip " + full_readme_file + " " + alaqilwin_dir_sf) and failed("")

print "Finished"

print "Now log in to SourceForge and set the operating systems applicable to the newly uploaded tarball and zip file. Also remember to do a 'git push --tags'."
