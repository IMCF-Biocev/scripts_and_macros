if (isOpen("Threshold")){
	selectWindow("Threshold");
	run("Close");
}
if (roiManager("Count") > 0){
	roiManager("Deselect");
	roiManager("Delete");
}
run("Clear Results");
run("Close All");
//setBatchMode(true); 

folder = getDirectory("Choose_Input_Directory (folder Images)");
folderm = getDirectory("Choose_Input_Directory (folder Masks)"); 
dir = getDirectory("Choose directory for saving results (Results)");
dirxy = getDirectory("Choose directory for saving results (XY)");
list = getFileList(folder); 
print(list[1]);

for (i=0; i < list.length; i++) { 
	if (roiManager("Count") > 0){
	roiManager("Deselect");
	roiManager("Delete");
	}
	if (endsWith(list[i], ".tif")) {
		print(list[i]);
		path = folder+list[i];
		open(path);
		imageName = getTitle();
		name = substring(imageName, 0, lastIndexOf(imageName, "."));
		open(folderm+name+"_mask.tif");
		maskName = getTitle();
		run("Save XY Coordinates...", "background=0 save=["+folderm+"/"+name+"_mask.csv]");
		
		selectWindow(imageName);
		run("32-bit");
		setOption("ScaleConversions", false);
		run("16-bit");
		
		run("Set Measurements...", "area mean min integrated median display redirect=None decimal=9");
		
		selectWindow(imageName);
		run("Measure");
		maxpixel = getResult("Max",0);
		run("Clear Results");
		
		selectWindow(maskName);
		run("Duplicate...", " ");
		rename("maskoutline");
		run("Outline");
		selectWindow(maskName);
		run("Create Selection");
		roiManager("add");
		run("Measure");
		maskArea = getResult("Area",0);
		run("Clear Results");
		
		selectWindow(imageName);
		run("Duplicate...", " ");
		rename("temp");
		roiManager("Select", 0);
		run("Clear Outside");
		//waitForUser("Checkpoint");
		selectWindow("temp");
		roiManager("Deselect");
		roiManager("Delete");
		setAutoThreshold("Moments dark");
		run("Threshold...");
		setThreshold(3800, maxpixel);
		run("Analyze Particles...", "size=2-Infinity pixel add");
		//waitForUser("Checkpoint");
		selectWindow(imageName);
		roiManager("Deselect");
		roiManager("Measure");
		selectWindow("Results");
		saveAs("Results", dir + "/" + name + "_decon_threshold_clusters.txt");
		run("Clear Results");
		
		selectWindow("temp");
		run("Find Maxima...", "prominence=1500 above output=[Segmented Particles]");
		rename("spots");
		imageCalculator("Add create", "spots","maskoutline");
		rename("cleaned_spots");
		//waitForUser("Checkpoint");
		selectWindow("cleaned_spots");
		roiManager("Deselect");
		roiManager("Delete");
		run("Analyze Particles...", "size=2-60 pixel show=Masks summarize add");
		selectWindow("Mask of cleaned_spots");
		rename("new_spots");
		//waitForUser("Checkpoint");
		saveAs(name+"_spots.tif", dir+name+"_spots.tif");
		//run("Close");
		selectWindow(imageName);
		roiManager("Deselect");
		roiManager("Measure");
		selectWindow("Results");
		saveAs("Results", dir + "/" + name + "_decon_single_spots.txt");
		run("Clear Results");
		
		
		selectWindow("Summary");
		IJ.renameResults("Summary","Results");
		spotArea = getResult("Total Area",0);
		spotCount = getResult("Count",0);
		countDensity = spotCount/maskArea;
		areaDensity = spotArea/maskArea;
		
		print("Name:", "\t", imageName);
		print("Area of mask:", "\t", maskArea);
		print("Area of spots:", "\t", spotArea);
		print("Area density:", "\t", areaDensity);
		print("Number of spots:", "\t", spotCount);
		print("Density:", "\t", countDensity);
		selectWindow("Log");
		saveAs("Text", dir + "/" + name + "_results.txt");
		 /*
		selectWindow("spots");
		roiManager("Show None");
		run("Close");
		run("Clear Results");
		selectWindow("temp");
		run("Find Maxima...", "prominence=1500 above output=[List]");
		selectWindow("Results");
		saveAs("Results", dir+name+"_xy.text");
		run("Close");
		selectWindow("temp");
		run("Find Maxima...", "prominence=1500 above output=[Single Points]");
		rename("coor");
		selectWindow("coor");
		saveAs(name+"_xy.tif", dir+name+"_xy.tif");
		 */
		selectImage(name+"_spots.tif");
		run("Find Maxima...", "prominence=1 light output=List");
		selectWindow("Results");
		run("Text...", "save=["+dirxy+"/"+name+"_xy.csv]");
		run("Clear Results");
		selectImage(name+"_spots.tif");
		run("Find Maxima...", "prominence=1 light output=[Single Points]");
		rename("coor");
		selectWindow("coor");
		saveAs(name+"_xy.tif", dirxy+name+"_xy.tif");
		run("Clear Results");
		
		run("Close All");
		}
}
