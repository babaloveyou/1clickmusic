import struct, string, time

dst = open("db.dat", "wb")
src = open("radios.pas", "r")
pasw = 704

def crypt(text):
    key = len(text) % 10
    result = ""
    for i in xrange(len(text)):
        result += chr( ( ord(text[i]) ^ ( (pasw * (i+1)) + key ) ) % 256)
    return result

def writeint8(num):
    data = struct.pack("B",num)
    dst.write(data)

def writestring(text):
    l = len(text)
    data = struct.pack("B" + str(l) + "s",l,text)
    dst.write(data)

def getarraysize(line):
    return int(line[line.find("..") + 2 : line.find("]")]) + 1

def getarraycontent(line):
    return line[line.find("'") + 1 : line.rfind("'")].replace("''","'")
	
def error(msg):
	print 'Houston, we have a problem on',msg
	raw_input()

bParse = False
iLevel = -2
genres = []
chn = []
pls = []
count = 0
totalcount = 0
tStart = time.clock()

#-2 genrelist array
#-1 content

# 0 chn_ array
# 1 content

# 2 pls_ array
# 3 content

for line in src:
    if "// " in line: # comented line
        continue
    
    if "const" in line:
        bParse = True

    elif ");" in line:
        bParse = False
        if iLevel < 3:
            iLevel += 1
        else:
            iLevel = 0
            
	    # check if both lists have same size
            if (len(chn) <> len(pls)) or (len(chn) <> count):
                error(genres.pop(0))

            slist = [] # a list that we will sort
            for i1, i2 in zip(chn,pls):
                slist.append((i1,i2))

            chn = []
            pls = []
            slist.sort()
            
            totalcount += count
            
            # write to file
            writestring(genres.pop(0))
            writeint8(count)
            for item in slist: # item = (chn, pls)
                writestring(item[0])
                writestring(item[1])
                
    elif bParse:
        if iLevel == -2:
            writeint8(getarraysize(line))
            iLevel += 1
        elif iLevel == -1:
            genres.append(getarraycontent(line))
        elif iLevel in (0,2):
            count = getarraysize(line)
            iLevel += 1
        elif iLevel == 1:
            chn.append(getarraycontent(line))
        elif iLevel == 3:
            pls.append(crypt(getarraycontent(line)))

dst.close()
src.close()

print "OK, %d radios sorted and saved in %fsec" % (totalcount, time.clock() - tStart)
raw_input()
