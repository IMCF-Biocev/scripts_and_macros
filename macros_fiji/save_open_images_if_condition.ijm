// single selected image
/*
getDimensions(width, height, channels, slices, frames);
print(slices);
filename = getTitle();
print(filename);
saveAs("Tiff", "C:/Users/zuzka/Desktop/rasy/experiment2/"+filename+".tif");
*/

// loop over opened images
list = getList("image.titles");
if (list.length==0)
	print("No image windows are open");
else {
	print("Image windows:");
}
	for (i=0; i<list.length; i++) {
		selectWindow(list[i]);
		filename = getTitle();
		filename = replace(filename, '/', '');
		getDimensions(width, height, channels, slices, frames);
		print(filename);
		print(slices);
		if (slices>1) {
			saveAs("Tiff", "C:/Users/zuzka/Desktop/rasy/experiment2/"+filename+".tif");
			close(list[i]);
		}
		else {
			close(list[i]);
		}
}