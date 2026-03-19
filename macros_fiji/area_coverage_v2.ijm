// area coverage extraction - Zuzana Čočková - cockovaz@natur.cuni.cz - January 2023
// additional plugins required: none

run("Close All");
roiManager("reset");	
run("Clear Results");
run("Set Measurements...", "area mean redirect=None decimal=3");


Dialog.create("Define input data");
antibodies = newArray("FTO", "METTL3");
Dialog.addRadioButtonGroup("Protein", antibodies, 2, 1, "FTO");
defaultPath = getDirectory("home");
Dialog.addFile("Path_to_DAPI image:", defaultPath);
Dialog.addFile("Path_to_NEUN image:", defaultPath);
Dialog.addFile("Path_to_protein (FTO/METTL3) image:", defaultPath);
dir = getDirectory("home");
Dialog.addDirectory("Select directory for saving results:", dir);
Dialog.show;
protein = Dialog.getRadioButton;
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
	
function getBG(dapi, neun, prot)
{
	setTool("rectangle");
	selectWindow(dapi);
	waitForUser("Select background area DAPI");
	run("Measure");
	bg = getResult("Mean", 0);
	run("Subtract...", "value="+bg);
	run("Select None");
	
	selectWindow(neun);
	waitForUser("Select background area NEUN");
	run("Measure");
	bg = getResult("Mean", 1);
	run("Subtract...", "value="+bg);
	run("Select None");
	
	selectWindow(prot);
	waitForUser("Select background area "+protein);
	run("Measure");
	bg = getResult("Mean", 2);
	run("Subtract...", "value="+bg);
	run("Select None");
	
	run("Tile");
}

function process(dapi, neun, prot, protein)
{
	run("Colors...", "foreground=black background=white selection=yellow");
	selectWindow(dapi);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=3"); 
	setAutoThreshold("Otsu dark");
	//run("Threshold...");
	//setThreshold(15, 255);
	run("Convert to Mask");
	rename("DAPI_mask")
	run("Duplicate...", " ");
	run("Invert");
	run("Divide...", "value=255.000");
	rename("DAPI-");
	selectWindow("DAPI_mask");
	run("Duplicate...", " ");
	run("Divide...", "value=255.000");
	rename("DAPI+");

	selectWindow(neun);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=3"); 
	setAutoThreshold("Otsu dark");
	//run("Threshold...");
	//setThreshold(10, 255);
	run("Convert to Mask");
	rename("NEUN_mask")
	run("Duplicate...", " ");
	run("Invert");
	run("Divide...", "value=255.000");
	rename("NEUN-");
	selectWindow("NEUN_mask");
	run("Duplicate...", " ");
	run("Divide...", "value=255.000");
	rename("NEUN+");

	selectWindow(prot);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=3"); 
	setAutoThreshold("Otsu dark");
	//run("Threshold...");
	setThreshold(25, 255);
	run("Convert to Mask");
	rename(protein + "_mask")
}


function imageOperations(protein, output_dir)
{
	imageCalculator("Multiply create", "NEUN_mask","DAPI+");
	rename("NEUNplusDAPIplus")
	//saveAs("Tiff", output_dir + "/" + "NEUNplusDAPIplus.tif");
	imageCalculator("Multiply create", "NEUN_mask","DAPI-");
	rename("NEUNplusDAPIminus")
	//saveAs("Tiff", output_dir + "/" + "NEUNplusDAPIminus.tif");
	imageCalculator("Multiply create", protein+"_mask","DAPI+");
	rename(protein+"plusDAPIplus")
	//saveAs("Tiff", output_dir + "/" + protein+"plusDAPIplus.tif");
	imageCalculator("Multiply create", protein+"_mask","NEUN+");
	rename(protein+"plusNEUNplus")
	//saveAs("Tiff", output_dir + "/" + protein+"plusNEUNplus.tif");
	imageCalculator("Multiply create", protein+"plusNEUNplus","DAPI+");
	rename(protein+"plusNEUNplusDAPIplus")
	//saveAs("Tiff", output_dir + "/" + protein+"plusNEUNplusDAPIplus.tif");
	imageCalculator("Multiply create", protein+"_mask","NEUN-");
	rename(protein+"plusNEUNminus")
	//saveAs("Tiff", output_dir + "/" + protein+"plusNEUNminus.tif");
	imageCalculator("Multiply create", protein+"plusNEUNminus","DAPI+");
	rename(protein+"plusNEUNminusDAPIplus")
	//saveAs("Tiff", output_dir + "/" + protein+"plusNEUNminusDAPIplus.tif");		
	
}

function subnuclearArea(protein)
{
	run("Clear Results");
	
	selectWindow("DAPI_mask");
	run("Analyze Particles...", "add");
	run("Select None");
	roiManager("multi-measure append");
	run("Select None");
	Table.rename("Results", "Results-1");
	
	imageCalculator("Add create 32-bit", "DAPI_mask",protein+"plusDAPIplus");
	run("Select None");
	roiManager("multi-measure append");

	rois_to_keep = newArray();
	selectWindow("DAPI_mask");
	getDimensions(width, height, channels, slices, frames);
	newImage("tDAPIwith"+protein, "8-bit", width, height, 1);

	for (i = 0; i < roiManager("count"); i++) {

		r1 = getResult("Mean", i);
		r2 = Table.get("Mean", i, "Results-1");
		if (r1>r2) {
			rois_to_keep = Array.concat(rois_to_keep,i);
		}
	}

	selectWindow("tDAPIwith"+protein);
	roiManager("Select", rois_to_keep);
	roiManager("Fill");	
	run("Select None");
	run("Invert");
	close("Result of DAPI_mask");
	close("Results-1");
	imageCalculator("Multiply create", "tDAPIwith"+protein,"DAPI+");
	rename("DAPIwith"+protein);
	run("Invert LUT");
	close("tDAPIwith"+protein);
	
	imageCalculator("Multiply create", "DAPIwith"+protein,"NEUN+");
	rename("NEUNplusDAPIwith"+protein);
	imageCalculator("Multiply create", "DAPIwith"+protein,"NEUN-");
	rename("NEUNminusDAPIwith"+protein);
	/*
	run("Erode");
	run("Erode");
	run("Erode");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	*/
}

function results(protein, output_dir)
{
	print("\\Clear");
	run("Clear Results");
	print("Group Area")

	images = newArray(
		"DAPI_mask", protein+"_mask", "NEUN_mask", 
		protein+"plusDAPIplus", "DAPIwith"+protein, 
		protein+"plusNEUNplus", protein+"plusNEUNplusDAPIplus", protein+"plusNEUNminusDAPIplus",
		"NEUNplusDAPIwith"+protein, "NEUNminusDAPIwith"+protein);
	for (i=0; i<images.length; i++) {
		selectWindow(images[i]);
		run("Create Selection");
		run("Measure");
		run("Select None");
		print(images[i] +" "+ getResult("Area", i));
	}
	close("DAPI+");
	close("DAPI-");
	close("NEUN-");
	close("NEUN+");
}

function coverage(protein, output_dir)
{
	print("");
	print("Group Relative_Area Description");
	print(protein+"+DAPI+/"+protein+"+ " + (getResult("Area", 3) / getResult("Area", 1)) + " protein_in_nucleus_(total)");
	print(protein+"+DAPI+/DAPIwith"+protein+" "+ (getResult("Area", 3) / getResult("Area", 4))+ " nuclear_protein_area_(total)");
	nm = (getResult("Area", 5) / getResult("Area", 1));
	inm = 1 - (getResult("Area", 5) / getResult("Area", 1));
	print(protein+"+NEUN+/"+protein+"+ " + nm + " protein_in_neurons");
	print(protein+"+NEUN+DAPI+/"+protein+"+NEUN+ " + (getResult("Area", 6) / getResult("Area", 5))+ " neuronal_protein_in_nucleus");
	print(protein+"+NEUN+DAPI-/"+protein+"+NEUN+ " + (1-(getResult("Area", 6) / getResult("Area", 5)))+ " neuronal_protein_in_cytoplasm");
	print(protein+"+NEUN+DAPI+/NEUN+DAPIwith"+protein+" " + (getResult("Area", 6) / getResult("Area", 8))+ " neuronal_nuclear_protein_area");
	print(protein+"+NEUN-/"+protein+"+ " + inm + " protein_in_non-neurons");
	print(protein+"+NEUN-DAPI+/"+protein+"+NEUN- " + (getResult("Area", 7) / ((getResult("Area", 1) - getResult("Area", 5))))+ " non-neuronal_protein_in_nucleus");
	print(protein+"+NEUN-DAPI-/"+protein+"+NEUN- " + (1-(getResult("Area", 7) / ((getResult("Area", 1) - getResult("Area", 5)))))+ " non-neuronal_protein_in_cytoplasm");
	print(protein+"+NEUN-DAPI+/NEUN-DAPIwith"+protein+" " + (getResult("Area", 7) / getResult("Area", 9))+ " non-neuronal_nuclear_protein_area");
	selectWindow("Log");
	saveAs("Text", output_dir + "/" + "Results_"+dapi+".txt");
	close("Log");
}

function montage(output_dir)
{
	selectWindow("DAPI_mask");
	//saveAs("Tiff", output_dir + "/" + "DAPI_mask.tif");
	selectWindow("NEUN_mask");
	//saveAs("Tiff", output_dir + "/" + "NEUN_mask.tif");
	selectWindow(protein + "_mask");
	//saveAs("Tiff", output_dir + "/" + protein + "_mask.tif");
	run("Images to Stack", "use");
	//run("Make Montage...", "columns=3 rows=6 scale=0.25 border=2 font=50 label use");
	saveAs("Tiff", output_dir + "/"+"_masks.tif");
	//run("Tile");
	//run("Close All");
	print("Finished!");
}


getBG(dapi, neun, prot);
process(dapi, neun, prot, protein);
imageOperations( protein, output_dir );
subnuclearArea(protein);
results(protein, output_dir);
coverage(protein, output_dir);
montage(output_dir);

