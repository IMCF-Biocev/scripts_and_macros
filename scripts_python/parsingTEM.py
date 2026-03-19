from glob import glob
import numpy as np

paths = sorted(glob('normalized_tiles/*.tif'))
print(paths[0])
image_names = [name.split('\\')[1] for name in paths]

with open('coordinates.txt', 'r') as f:
        rows = f.readlines()[3:]

all_coords = []
for name, row in zip(image_names, rows):
    indicies = range(5,7)
    coords = ()
    for i in indicies:
        coord = row.split(' ')[i]
        print(coord)
        coords = coords + (float(coord),)
    all_coords.append(coords)

    # to_write.write(f'{name}; ; {coords}\n')
# to_write.close()
all_coords = np.array(all_coords)
maximum = np.max(all_coords.T[1])
new_y = [abs(i - maximum) for i in all_coords.T[1]]
new_x = all_coords.T[0]
coords = [(x,y) for x,y in zip(new_x,new_y)]


to_write = open('configuration_file.txt', 'a')
to_write.write('dim = 2\n')

for name, row, coord in zip(image_names, rows, coords):
    print(name)
    to_write.write(f'{name}; ; {coord}\n')

to_write.close()

