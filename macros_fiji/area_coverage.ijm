//batch processing
//input_dir = getDirectory("Choose image folder");
run("Close All");
roiManager("reset");	
run("Clear Results");
	

filedapi = File.openDialog("select dapi image"); 
fileneun = File.openDialog("select neun image"); 
filemettl3 = File.openDialog("select mettl3 image"); 

output_dir = getDirectory("Choose output folder");
run("Set Measurements...", "area mean redirect=None decimal=3");

open(filedapi);
dapi = getTitle();
open(fileneun);
neun = getTitle();
open(filemettl3);
mettl3 = getTitle();
	
function getBG(dapi, neun, mettl3)
{
	//setTool("rectangle");
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
	
	selectWindow(mettl3);
	waitForUser("Select background area METTL3");
	run("Measure");
	bg = getResult("Mean", 2);
	run("Subtract...", "value="+bg);
	run("Select None");
	
	run("Tile");
}

function process(dapi, neun, mettl3)
{
	selectWindow(dapi);
	//title = getTitle();
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
	//title = getTitle();
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

	selectWindow(mettl3);
	//title = getTitle();
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=3"); 
	setAutoThreshold("Otsu dark");
	//run("Threshold...");
	//setThreshold(10, 255);
	run("Convert to Mask");
	rename("METTL3_mask")
}

function imageOperations( output_dir )
{
	imageCalculator("Multiply create", "NEUN_mask","DAPI+");
	saveAs("Tiff", output_dir + "/" + "NEUNplusDAPIplus.tif");
	imageCalculator("Multiply create", "NEUN_mask","DAPI-");
	saveAs("Tiff", output_dir + "/" + "NEUNplusDAPIminus.tif");
	imageCalculator("Multiply create", "METTL3_mask","DAPI+");
	saveAs("Tiff", output_dir + "/" + "METTL3plusDAPIplus.tif");
	imageCalculator("Multiply create", "METTL3_mask","NEUN+");
	saveAs("Tiff", output_dir + "/" + "METTL3plusNEUNplus.tif");
	imageCalculator("Multiply create", "METTL3plusNEUNplus.tif","DAPI+");
	saveAs("Tiff", output_dir + "/" + "METTL3plusNEUNplusDAPIplus.tif");
	imageCalculator("Multiply create", "METTL3_mask","NEUN-");
	saveAs("Tiff", output_dir + "/" + "METTL3plusNEUNminus.tif");
	imageCalculator("Multiply create", "METTL3plusNEUNminus.tif","DAPI+");
	saveAs("Tiff", output_dir + "/" + "METTL3plusNEUNminusDAPIplus.tif");
	run("Tile");		
	
}

function results()
{
	print("Group Area")
	images = newArray("DAPI_mask", "METTL3_mask", "NEUN_mask", "METTL3plusDAPIplus.tif", "METTL3plusNEUNplus.tif", "METTL3plusNEUNplusDAPIplus.tif", "METTL3plusNEUNminusDAPIplus.tif" );
	for (i=0; i<images.length; i++) {
		selectWindow(images[i]);
		run("Create Selection");
		run("Measure");
		print(images[i] +" "+ getResult("Area", 3+i));
	
	}
}

function coverage( output_dir)
	{
	print("");
	print("Group %Area");
	print("METTL+DAPI+/METTL+ " + (getResult("Area", 6) / getResult("Area", 4)));
	nm = (getResult("Area", 7) / getResult("Area", 4));
	inm = 1 - (getResult("Area", 7) / getResult("Area", 4));
	print("METTL+NEUN+/METTL+ " + nm);
	print("METTL+NEUN+DAPI+/METTL+NEUN+ " + (getResult("Area", 8) / getResult("Area", 7)));
	print("METTL+NEUN+DAPI-/METTL+NEUN+ " + (1-(getResult("Area", 8) / getResult("Area", 7))));
	print("METTL+NEUN-/METTL+ " + inm);
	print("METTL+NEUN-DAPI+/METTL+NEUN- " + (getResult("Area", 9) / ((getResult("Area", 4) - getResult("Area", 7)))));
	print("METTL+NEUN-DAPI-/METTL+NEUN- " + (1-(getResult("Area", 9) / ((getResult("Area", 4) - getResult("Area", 7))))));
	
	selectWindow("Log");
	saveAs("Text", output_dir + "/" + "Results.txt");
	close("Log");
	}

getBG(dapi, neun, mettl3)
process(dapi, neun, mettl3)
imageOperations( output_dir )
results()
coverage( output_dir )
//print(File.getParent(filedapi));
//print(File.getName(filedapi));
