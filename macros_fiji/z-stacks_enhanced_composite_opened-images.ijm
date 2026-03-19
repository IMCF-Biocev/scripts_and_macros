list = getList("image.titles");
if (list.length==0)
  print("No image windows are open");
else {
  print("Image windows:");
for (i=0; i<list.length; i++) {
	//print("   "+list[i]);
	selectWindow(list[i]);
	run("Z Project...", "projection=[Max Intensity]");
	run("Enhance Contrast", "saturated=0.35");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	Property.set("CompositeProjection", "Sum");
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels("01010");
	//selectWindow(list[i]);
	close(list[i]);
  }
print("");
run("Tile");
 