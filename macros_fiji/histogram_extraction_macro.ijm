/*  Zuzana Cockova @IMCF (cockovaz@natur.cuni.cz)
 *  macro for histogram data extraction from images
 *  inputs: directory with .tif images 
 *  outputs: .csv table
 *  required additional plugins outside Fiji: none
 */


// defined functions
function init() { 
	// initialize ImageJ to clean state and prepare it for fresh run
	run("Clear Results");
	run("Close All");
}

// set Batch processing
setBatchMode(true); 

// initialize ImageJ
init(); 

// get info from user to images
DIRIN = getDirectory("Choose directory with images");
nBins = getNumber("Enter number of bins:", 256);

// list files in directory with images
list = getFileList(DIRIN); 

// create table for results
Table.create("Table"); 

// process every .tif image in input directory
for (i=0; i < list.length; i++) { 
		
	if (endsWith(list[i], ".tif")) { // if file is .tif
		
		fileName = replace(list[i], ".tif", ""); // get name without .tif extension
		
		path = DIRIN+list[i]; // get path to this file
		open(path); // open it
		
		getHistogram(values, counts, nBins); //get histogram
		
		Table.setColumn("Bins", values); // add column to results table
		Table.setColumn(fileName, counts); // add column to results table
		
		run("Close All");
	}
	
}		

// save result table to input dir
saveAs("Results", DIRIN+"histrogram_bins.csv");
close("histrogram_bins.csv");

setBatchMode(false);
