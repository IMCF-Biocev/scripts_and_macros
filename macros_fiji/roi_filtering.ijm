run("Clear Results");
roiManager("reset");
run("Colors...", "foreground=black background=white selection=yellow");
imageCalculator("Average create", "01mut_sem1b_spots.tif","01mut_sem1b_mask.tif");
selectWindow("Result of 01mut_sem1b_spots.tif");
setThreshold(1, 255, "raw");
run("Analyze Particles...", "  show=Nothing add composite");
selectWindow("Result of 01mut_sem1b_spots.tif");
roiManager("Deselect");
roiManager("Measure");

forRemoval = newArray();
numROIs = roiManager("count");
for(i=0; i<numROIs;i++){
	x=getResult("Max", i);
    if (x < 255){
    	forRemoval = Array.concat(forRemoval, i);
    }   
}
/*
for(i=0; i<numROIs;i++){
    roiManager("Select", i); 
    getStatistics(area, mean, min, max, std, histogram);
    if (max < 255){
      forRemoval = Array.concat(forRemoval, i);
    }   
}
*/

roiManager("Select", forRemoval);
roiManager("Delete");
wait(5);
roiManager("Deselect");
numROIsUp = roiManager("count");
print(numROIsUp);
//array = newArray(numROIsUp);
for (i=0; i<numROIsUp; i++) {
	//array[i] = i;
	selectWindow("01mut_sem1b_spots.tif");
    roiManager("Select", i);
	run("Clear", "slice");
	}
//selectWindow("01mut_sem1b_spots.tif");
//roiManager("select", array);
//run("Fill", "slice");
