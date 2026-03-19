import os

dir = "/home/zuzka/Documents/BIOCEV_projects/1RA_tilescan"
dir = "/home/zuzka/Documents/BIOCEV_projects/310_28A"
os.chdir(dir)
print(os.getcwd())
 
for count, f in enumerate(sorted(os.listdir())):
    f_name, f_ext = os.path.splitext(f)
    print(count + 1, f_name)
    f_name = "tile" + str("{0:03}".format(count+1))
    new_name = f'{f_name}{f_ext}'
    os.rename(f, new_name)

print(f_name)
