imageName = getTitle();
name = substring(imageName, 0, lastIndexOf(imageName, "."));
dir = getDirectory("choose directory for saving results");

if (roiManager("Count") > 0){
	roiManager("Show None");
	roiManager("Delete");
}
if (isOpen("Threshold")){
	selectWindow("Threshold");
	run("Close");
}
if (isOpen("Results")){
	selectWindow("Results");
	run("Close");
}

selectWindow(imageName);
run("32-bit");
setOption("ScaleConversions", false);
run("16-bit");

run("Set Measurements...", "area mean min integrated median display redirect=None decimal=9");

selectWindow(imageName);
run("Measure");
maxpixel = getResult("Max",0);
selectWindow("Results");
run("Close");

selectWindow(imageName);
run("Duplicate...", " ");
rename("Pic1");
run("Duplicate...", " ");
rename("Pic2");
selectWindow("Pic1");
run("Gaussian Blur...", "sigma=5");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(10, maxpixel);
waitForUser("Threshold oblasti cele bunky...");
//run("Threshold...");

setOption("BlackBackground", false);
run("Convert to Mask");
run("Fill Holes"); // není dobré pro vlákna
selectWindow("Pic2");
run("Gaussian Blur...", "sigma=5");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(70, maxpixel);
waitForUser("Threshold oblasti s cytoplasmou...");
//run("Threshold...");

run("Convert to Mask");
run("Size Opening 2D/3D", "min=1000");
selectWindow("Pic2-sizeOpen");
imageCalculator("Subtract create", "Pic1","Pic2-sizeOpen");
rename("res");
selectWindow("Pic1");
run("Close");
selectWindow("Pic2");
run("Close");
selectWindow("Pic2-sizeOpen");
run("Close");
selectWindow("res");
run("Erode");
run("Size Opening 2D/3D", "min=1000");
rename(name+"_mask");
run("Create Selection");
roiManager("Add");
selectWindow("res");
run("Close");
//charray = newArray("Pic1", "Pic2", "res");
//Array.print(charray);
//for (i=0; i<charray.length; i++); 
//	print(charray[i])
	//selectWindow(array[i]);
	//run("Close")
selectWindow(imageName);
roiManager("Select", 0);
waitForUser("Waiting for manual changes. Press Okay to continue....");

selectWindow(name+"_mask");
saveAs(name+"_mask.tif", dir + "/" + name+"_mask.tif");
