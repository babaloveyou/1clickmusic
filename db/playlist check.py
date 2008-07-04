import httplib, urllib , sys, threading

level = 1;

sons = []

def ex(line):
    if "http://" in line and (".pls" in line.lower() or ".m3u" in line.lower()):
        url = line.split("'")[1]
        pendingurls.append( (url.split(".")[1],url) )


class son(threading.Thread):
    def __init__(self,name,url):
        self.name = name
        self.url = url
        threading.Thread.__init__(self)
    def run(self):
        try:
            ok = False;
            target = urllib.urlopen(self.url)
            for line in target:
                if ("://" in line):
                    ok = True;
                    break
            if ok == False:
                print "-------------------"
                print self.name, "?", "!"
                print self.url
                print "-------------------"
                
            target.close()

        except:
            if level > 0:
                print "-------------------"
                print self.name, "?", "!"
                print self.url
                print "-------------------"
        finally:
            sons.remove(self)


pendingurls = []


plsfile = open("radios.pas")
for line in plsfile:
    ex(line)
plsfile.close()

for item in pendingurls:
    curson = son(item[0],item[1])
    sons.append(curson)
    curson.start()

while len(sons) > 0:
    pass

print "done!!!"
raw_input()


