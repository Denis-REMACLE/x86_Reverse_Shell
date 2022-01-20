import argparse
import operator

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

    return port

#def copy_and_modify(version, name, ip, port):

if __name__ == "__main__":

    # Argparse ain't that hard to use
    # You just need to initialize the ArgumentParser
    # You can use the data in the argument later 
    parser = argparse.ArgumentParser()

    # Then initialize the arguments
    parser.add_argument("--shellcode-it", "-s", default=False, action="store_true")
    parser.add_argument("--version", "-v", default="reverser.asm", type=str)
    parser.add_argument("--ip-address", "-i", default="127.0.0.1", type=str)
    parser.add_argument("--port", "-p", default="8080", type=str)
    parser.add_argument("--name", "-n", default="reverser_default", type=str)

    # and then parse it
    args = parser.parse_args()

    ip = ip_treatment(args.ip_address)
    port = port_treatment(args.port)