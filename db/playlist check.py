import time, urllib , sys, threading

workers = []
pendingurls = []

def ex(line):
    if "http://" in line: #and (".pls" in line.lower() or ".m3u" in line.lower()):
        url = line.split("'")[1]
        pendingurls.append(url)


class Worker(threading.Thread):
    def run(self):
        while pendingurls:
            try:
                ok = False
                url = pendingurls.pop()
                target = urllib.urlopen(url)
                if target.getcode() == 200:
                    for line in target:
                        if ("://" in line):
                            ok = True;
                            break
                if not ok:
                    print "-------------------"
                    print url
                    print "-------------------"
                #else:
                #    print self.n ,"ok"

            except:
                print "-------------------"
                print url
                print "-------------------"
        workers.remove(self)


pendingurls = []

print "parsing file"
plsfile = open("radios.pas")
for line in plsfile:
    ex(line)
plsfile.close()

print "starting threads"
for i in range(10):
    worker = Worker()
    workers.append(worker)
    worker.start()

print "waiting threads"
   
while workers:
    time.sleep(1)
    print len(pendingurls),"remaining"

print "done!!!"
raw_input()


