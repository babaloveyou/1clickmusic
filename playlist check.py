import httplib, urllib , sys, threading

sons = []

def ex(line):
    if "http://" in line:
        url = line.split("'")[1]
        pendingurls.append( (url.split(".")[1],url) )


class son(threading.Thread):
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
            if r1.status != 200:
                print self.name, r1.status, r1.reason
                print self.url

        except:
            print "error!", sys.exc_info()[0]
            print self.host , self.target
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


