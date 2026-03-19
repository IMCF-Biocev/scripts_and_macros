// select folder and open files
run("Close All")
folder = getDirectory("Choose_Images_Directory");
folderOUT = getDirectory("Choose_Output_Masks_Directory"); 
list = getFileList(folder); 
run("Clear Results");
//setBatchMode(true); 
print(substring("LSM_7_d1_f 0", 0, lastIndexOf("LSM_7_d1_f 0", "_")));

for (i=0; i < list.length; i++) { 
	roiManager("reset");	
	if (endsWith(list[i], " 0.tif")) {
		rgbi = folder + list[i];
		name0 = substring(list[i], 0, lastIndexOf(list[i], "."));
		name = substring(name0, 0, lastIndexOf(name0, " "));
		name = replace(name, "d1", "d3");
		print(name);
		ch1i = folder + name + " 0Filter.tif";
		ch2i = folder + name + " 1Filter.tif";
		open(rgbi);
		rgb = getTitle();
		open(ch1i);
		ch1 = getTitle();
		run("Duplicate...", " ");
		ch1d = getTitle();
		selectWindow(rgb);
		run("Enhance Contrast", "saturated=0.3");
		run("Duplicate...", " ");
		saveAs("Tiff", folderOUT+name+"_enhanced.tif");
		close(name+"_enhanced.tif");
		selectWindow(rgb);
		run("Split Channels");
		//close(rgb + " (blue)");
		close(rgb + " (green)");
		selectWindow(rgb + " (red)");
		run("Gaussian Blur...", "sigma=2");
		selectWindow(ch1);
		run("Gaussian Blur...", "sigma=2");
		run("Invert");
		imageCalculator("Divide create", ch1,rgb+" (red)");
		selectWindow(ch1);
		setAutoThreshold("Default dark");
		//run("Threshold...");
		setAutoThreshold("Huang");
		setThreshold(1, 65531); //zkusime
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Erode");
		run("Erode");
		saveAs("Tiff", folderOUT+name+"_cell.tif");
		run("Create Selection");
		run("Make Inverse");
		roiManager("Add");
		selectWindow("Result of "+ch1);
		roiManager("Select", 0);
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Select None");
		run("Fire");
		saveAs("Tiff", folderOUT+name+"_nuc.tif");
		
		open(ch2i);
		ch2 = getTitle();
		run("Gaussian Blur...", "sigma=2");
		setAutoThreshold("Li dark");
		run("Convert to Mask");
		run("Create Selection");
		roiManager("Add");
		close(ch2);
		/*
		run("Subtract Background...", "rolling=50");
		setAutoThreshold("Minimum dark");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Dilate");
		run("Dilate");
		saveAs("Tiff", folderOUT+name+"_melan.tif");
		*/
		selectWindow(rgb + " (blue)");
		run("Gaussian Blur...", "sigma=2");
		imageCalculator("Subtract create", rgb +" (blue)",rgb +" (red)");
		setAutoThreshold("Yen dark");
		setThreshold(5, 255);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		//roiManager("Select", 1);
		//run("Clear Outside");
		run("Dilate");
		//run("Dilate");
		saveAs("Tiff", folderOUT+name+"_melan.tif");
		run("Create Selection");
		roiManager("Add");
		
		selectWindow(ch1d);
		run("Subtract Background...", "rolling=50");
		run("Median...", "radius=2");
		roiManager("Select", 2);
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Select None");
		setAutoThreshold("Otsu dark");
		run("Convert to Mask");
		run("Dilate");
		roiManager("Select", 2);
		run("Clear", "slice");
		run("Select None");
		saveAs("Tiff", folderOUT+name+"_mito.tif");
		
		close(rgb +" (blue)");
		close(rgb +" (red)");
		}
	}
//run("Tile");
run("Close All");