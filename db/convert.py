import struct, string, time, os

pasw = 704

dst = []

def crypt(text):
    text = text.replace("http://", "")
    key = len(text) % 10
    result = ""
    for i in xrange(len(text)):
        result += chr( ( ord(text[i]) ^ ( (pasw * (i+1)) + key ) ) % 256)
    return result

def writeint8(num):
    data = struct.pack("B",num)
    dst.append(data)

def writestring(text):
    l = len(text)
    data = struct.pack("B" + str(l) + "s",l,text)
    dst.append(data)

def getarraysize(line):
    return int(line[line.find("..") + 2 : line.find("]")]) + 1

def getarraycontent(line):
    return line[line.find("'") + 1 : line.rfind("'")].replace("''","'")
	
def error(msg):
	print 'Houston, we have a problem'
	print msg
	raw_input()

bParse = False
iLevel = -2
genres = []
chn = []
pls = []
totalcount = 0
tStart = time.clock()

srcfile = open("radios.pas", "r")

#   -2    genrelist array
#   -1    content

#   0     chn_ array
#   1     content

#   2     pls_ array
#   3     content

for line in srcfile:
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
            if len(chn) <> len(pls):
                error("%s chn=%d pls=%d" % (genres[0], len(chn), len(pls)))

            slist = [] # a list that we will sort
            for i1, i2 in zip(chn,pls):
                slist.append((i1,i2))

            chn = []
            pls = []
            slist.sort()
            
            totalcount += len(slist)

            print "%s %d" % (genres[0], len(slist))
            
            # write to file
            dst.append('\n');
            dst.append('+' + genres.pop(0) + '\n')
            for i1, i2 in slist:
                dst.append('-' + i1 + '\n')
                dst.append('1' + i2 + '\n')
                
    elif bParse:
        if iLevel == -2:
            size = getarraysize(line)
            print "%d genres" % size
            iLevel += 1
        elif iLevel == -1:
            genres.append(getarraycontent(line))
        elif iLevel in (0,2):
            iLevel += 1
        elif iLevel == 1:
            chn.append(getarraycontent(line))
        elif iLevel == 3:
            pls.append(getarraycontent(line))

dst = "".join(dst)
srcfile.close()

dstfile = open("result.txt","w")

dstfile.writelines(dst)

dstfile.close()

print "OK, %d radios converted and saved in %fs" % (totalcount, time.clock() - tStart)
raw_input()
