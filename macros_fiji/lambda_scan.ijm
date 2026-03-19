run("Set Measurements...", "area mean integrated redirect=None decimal=3");

title = getTitle();
selectWindow(title);

//run("Duplicate...", "duplicate");
//run("Z Project...", "projection=[Sum Slices]");
//run("Threshold...");
setThreshold(4, 255);
setAutoThreshold("Default dark stack");
run("Convert to Mask", "method=Default background=Dark create");

selectWindow("MASK_"+title);
for (i=1; i<nSlices+1;i++) {
	print(i);
	setSlice(i);
	print(getSliceNumber()); 	
	run("Create Selection");
	roiManager("Add");

}
selectWindow(title);
for (i=1; i<nSlices+1;i++) {
	setSlice(i); 	
	roiManager("Select", i-1);
	run("Measure");
}
