extlist = [".bk1",".bk2",".$$$",".local",".a",".tmp",".drc",".o",".cfg",".ddp",
           ".stat",".pec2bac",".identcache",".dcu",".ppu",".depend",".layout",".win"] #put extensions to delete

import sys, os, subprocess

print "START THE CLEARING PROCESS"
print "DELETING FILES WITH THE FOLLOWING EXT"
print extlist
i = 0
for root, dirs, files in os.walk(os.getcwd()):
    for file in files:
        #for ext in extlist:
        fileext = os.path.splitext(file)[1]
        if fileext in extlist:
                filepath = os.path.join(root,file)
                print filepath
                os.remove(filepath)
                i+=1

print "%d files found and deleted" % i
print "Exiting..."
