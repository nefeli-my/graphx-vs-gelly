import igraph as ig
import time
import argparse
import sys

def convert_bytes(bytes_number):
    tags = [ "Byte", "Kilobyte", "Megabyte", "Gigabyte", "Terabyte" ]
 
    i = 0
    double_bytes = bytes_number
 
    while (i < len(tags) and  bytes_number >= 1024):
            double_bytes = bytes_number / 1024.0
            i = i + 1
            bytes_number = bytes_number / 1024
 
    return str(round(double_bytes, 2)) + " " + tags[i]

def calc_size(g):
    # helper function
    # calculate an approximation of the size
    # of a generated graph g
    V = g.vcount()
    E = g.ecount()
    print(V, E)

    vertexID = 8   # bytes, according to frameworks' documentation
    edgeID = 2*8   # bytes, edges identified by srcId, dstId
    
    # all atrributes of edges and vertices 
    # set to 1 during graph creation
    # int size in java: 4 bytes 
    attr = 4       
    size = V*(vertexID + attr) + E*(edgeID + attr)
    
    return convert_bytes(size)

def generate(random, size,  makefiles):
    n1 = 100000     # 100K nodes
    n2 = 500000     # 500K nodes
    n3 = 1000000    # 1M   nodes

    gen = 'Erdos-Renyi' if random else 'Barabasi'
    print(f'Generator:{gen}, Size:{size}, Make Files:{makefiles}')
    t1 = time.time()
    
    if random:
        # p parameter values set as in the test datasets
        if size == "Small":
            g = ig.Graph.Erdos_Renyi(n=n1, p=0.0001)
        elif size == "Medium":
            g = ig.Graph.Erdos_Renyi(n=n2, p=0.0001)
        else:
            g = ig.Graph.Erdos_Renyi(n=n3, p=0.0001)
    else:
        # m parameter values set as in the test datasets
        if size == "Small":
            g = ig.Graph.Barabasi(n1, m=5)
        elif size == "Medium":
            g = ig.Graph.Barabasi(n2, m=25)
        else:
            g = ig.Graph.Barabasi(n3, m=25)

    t2 = time.time()
    print(f'graph creation: {str(t2-t1)}s')
    print(f'graph size: {calc_size(g)}')
    
    if makefiles:
        V = g.vcount()
        E = g.ecount()
        
        with open(f'{gen}_{size}_{V}_{E}_nodes.txt', 'w') as f:
            vertices = g.vs.indices
            for v in vertices:
                f.write(f'{v}, 1\n')
        
        with open(f'{gen}_{size}_{V}_{E}_edges.txt', 'w') as f:
            for edge in g.es:
                f.write(f'{edge.source} {edge.target} 1\n')

        t3 = time.time()
        print(f'files creation: {str(t3-t2)}s')

              
if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Graph generation",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--random", type=str, help="create random graph, default: True")
    parser.add_argument("--size", type=str, help="desired size, options: Small, Medium, Large, default: Small")
    parser.add_argument("--makefiles", type=str, help="create edge list and nodes files, default: True")
    args = parser.parse_args()
    config = vars(args)

    if len(sys.argv) > 7:
        print(config)
        
    else:    
        if args.random == None:   
            random = True
        elif args.random not in ["True", "False"]:
            parser.print_help()
        else:
            random = args.random == "True"
        		
        if args.size == None:
            size = "Small"
        elif args.size not in ["Small", "Medium", "Large"]:
            parser.print_help()
        else:
            size = args.size

        if args.makefiles == None:   
            makefiles = True
        elif args.makefiles not in ["True", "False"]:
            parser.print_help()
        else:
            makefiles = args.makefiles == "True"
			
        generate(random, size, makefiles)
            
