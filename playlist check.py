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
            target = urllib.urlopen(self.url)
            text = target.read().lower()
            if not("404" in text or "error" in text or "found" in text):
                for line in target:
                    if ("http://" in line) and not("#" in line):
                        curson = son2(self.url.split(".")[1],line)
                        sons.append(curson)
                        curson.start()
            else:
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


class son2(threading.Thread):
    def __init__(self,name,url):
        self.fullurl = url
        url = url.split("://",1)[1]

        values = url.split("/",1)
        if len(values) == 1: values = (values[0],"")

        self.host , self.target = values
        self.target = '/'+ self.target
        self.url = url
        self.name = name
        threading.Thread.__init__(self)
    def run(self):
        try:
            conn = httplib.HTTPConnection(self.host)
            conn.request("GET", self.target,None,{"User-Agent": "1ClickMusic/1.7.1","Accept": "*/*"})
            r1 = conn.getresponse()
            if r1.status not in (200,302):
                print "-------------------"
                print self.name, r1.status, r1.reason
                print self.url
                print "-------------------"

        except:
            if level > 0:
                print "-------------------"
                print self.name, "?", sys.exc_info()[0]
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


