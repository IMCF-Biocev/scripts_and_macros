roiManager("reset");
selectWindow("ROI Manager");
run("Close");

if (isOpen("Results")){
	selectWindow("Results");
	run("Close");
	}


waitForUser("cell picture");
cellmask = getTitle();
waitForUser("mitochondria picture");
mitomask = getTitle();
//selectWindow("cellmask");
//cellmask = "control_final_cell.tif";
//mitomask = "control_final_v2_mito.tif";
//n=15;
buffer = 10;
rectWidth = 500;
rectHeight = 500;
run("Set Measurements...", "area mean area_fraction redirect=None decimal=3");

selectWindow(cellmask);
numslices = nSlices;
for (a = 1; a <= numslices; a++) {
	roiManager("reset");
	selectWindow("ROI Manager");
	run("Close");

	if (isOpen("Results")){
		selectWindow("Results");
		run("Close");
	}
	selectWindow(mitomask);
    setSlice(a);
    selectWindow(cellmask);
    setSlice(a);  
    n = 15;  // number of squares searched
	for (i = 0; i < n; i=i+1) {
		x = random() * (2048 - rectWidth);
		y = random() * (2048 - rectHeight);
		setTool("rectangle");
		makeRectangle(x+buffer, y-buffer, rectWidth, rectHeight);
		roiManager("Add");
		//selectWindow(cellmask);
		roiManager("Select", i);
		run("Measure");
		avg = getResult("%Area", i);
		if (avg < 30) {
			roiManager("Select", i);
			roiManager("rename", "del");
			n = n+1;
		}
	}

	for (x = 0; x < roiManager("count"); x=x+1) {
		roiManager("Select", x);
		if (Roi.getName == "del") {
			roiManager("delete");
			x--;
		}
	}

	selectWindow(mitomask);
	//run("Threshold...");
	setAutoThreshold("Default dark");
	//setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark black");

	for (y = 0; y < roiManager("count"); y=y+1) {
		roiManager("Select", y);
		run("Analyze Particles...", "  show=Nothing display exclude summarize slice");
		//selectWindow("name");
		//filesave = folderOUT+"Summary of control_final_v2_mito"
		//saveAs("Results", "F:/Users/Cockova/Tietzova_tem/unzoomed/Summary of control_final_v2_mito.csv");
	}
	
	run("Clear Results");
	wait(30);
	selectWindow(cellmask);
	for (z = 0; z < roiManager("count"); z=z+1) {
		roiManager("Select", z);
		run("Measure");
	}
	selectWindow("Results");
	saveAs("Results", "F:/Users/Cockova/Tietzova_tem/unzoomed/tables/cell_area_in_square_"+a+".csv");

}
selectWindow("Summary of "+mitomask);
saveAs("Results", "F:/Users/Cockova/Tietzova_tem/unzoomed/tables/mito_in_square_"+cellmask+".csv");



