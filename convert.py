pas = 704
def encode(srcstr,match):
    result = ""
    key = len(match) % 10
    for i in xrange(len(match)):
        if match[i] != "'":
            result += "#"+ str( ( ord(match[i]) ^ ( (pas * (i+1)) + key ) ) % 256)

    if "'," in srcstr:
        result += ","

    return result + "//" + match + "\n"

source = open('radios.pas','r')
dest = open('radios_.pas','w')

for line in source:
    if line == "unit radios;\n" : line = "unit radios_;\n";
    match = ("://" in line) and (not "// " in line)
    if match:
        dest.write(encode(line,line.split("'")[1]))
    else:
        dest.write(line)

source.close()
dest.close()