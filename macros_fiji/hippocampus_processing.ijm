// hippocampus area split - Zuzana Čočková - cockovaz@natur.cuni.cz - January 2023

function area_clean(filearr, output_dir)
{
	for (i = 0; i < filearr.length; i++) {
		selectWindow(filearr[i]);
		run("Select None");
		run("Duplicate...", " ");
		rename("img1");
		roiManager("Select", 0);
		run("Clear Outside");
		run("Select None");
		saveAs("Tiff", output_dir + "/GD_" + filearr[i]);
		selectWindow(filearr[i]);
		roiManager("Select", 0);
		run("Clear", "slice");
		run("Select None");
		saveAs("Tiff", output_dir + "/R_" + filearr[i]);	
	 }
}

function dapi_threshold(dapi)
{
	selectWindow(dapi);
	run("Duplicate...", " ");
	rename("mask");
	setAutoThreshold("Huang dark");
	//setThreshold(20, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Keep Largest Region");
	for (i = 1; i < 10; i++) {
		run("Dilate");
	}
	run("Create Selection");
	roiManager("Add");
	close("mask");
	close("mask-largest");
}

function init()
{
	run("Close All");
	roiManager("reset");	
	run("Clear Results");
	print("\\Clear");
	run("Colors...", "foreground=white background=black selection=yellow");
}

init();

Dialog.create("Define input data");
defaultPath = getDirectory("home");
Dialog.addFile("Path_to_DAPI image:", defaultPath);
Dialog.addFile("Path_to_NEUN image:", defaultPath);
Dialog.addFile("Path_to_protein (FTO/METTL3) image:", defaultPath);
dir = getDirectory("home");
Dialog.addDirectory("Select directory for saving results:", dir);
Dialog.show;
filedapi = Dialog.getString();
fileneun = Dialog.getString();
fileprot = Dialog.getString();
output_dir = Dialog.getString();

open(filedapi);
dapi = getTitle();
open(fileneun);
neun = getTitle();
open(fileprot);
prot = getTitle();
filearr = newArray(dapi, neun, prot);

dapi_threshold(dapi);

selectWindow(dapi);
roiManager("Select", 0);
if (getBoolean("Is gyrus dentatus selected?")) {
 	area_clean(filearr, output_dir);
} else {
	roiManager("reset");
	selectWindow(filearr[1]);
	run("Select None");
	setTool("polygon");
	waitForUser("Select gyrus dentatus area.");
	roiManager("Add");
	area_clean(filearr, output_dir);
}
run("Close All");
print("Finished!");


