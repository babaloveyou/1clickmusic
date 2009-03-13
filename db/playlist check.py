import time, urllib , sys, threading

level = 1;

sons = []

def ex(line):
    if "http://" in line: #and (".pls" in line.lower() or ".m3u" in line.lower()):
        url = line.split("'")[1]
        pendingurls.append(url)


class son(threading.Thread):
    def __init__(self,url):
        self.url = url
        threading.Thread.__init__(self)
    def run(self):
        try:
            ok = False
            target = urllib.urlopen(self.url)
            if target.getcode() == 200:
                for line in target:
                    if ("://" in line):
                        ok = True;
                        break
            if not ok:
                print "-------------------"
                print self.url
                print "-------------------"
            #else:
            #    print self.n ,"ok"

        except:
            if level > 0:
                print "-------------------"
                print self.url
                print "-------------------"
        finally:
            sons.remove(self)


pendingurls = []

print "parsing file"
plsfile = open("radios.pas")
for line in plsfile:
    ex(line)
plsfile.close()

print "starting threads"
for item in pendingurls:
    curson = son(item)
    sons.append(curson)
    curson.start()

print "waiting threads"
   
while len(sons) > 0:
    time.sleep(5)
    print len(sons),"remaining"

print "done!!!"
raw_input()


