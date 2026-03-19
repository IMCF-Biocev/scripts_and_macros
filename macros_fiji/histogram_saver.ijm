dir = getDirectory("Directory path");
list = getList("image.titles");
if (list.length==0)
  print("No image windows are open.");
else {
  //print("Image windows are open."); 
  	run("Clear Results");
    }
    
nBins = 22; //depends on selected channels for ratio images - eg. range 2.2 by 0.1 = 22 bins
for (i=0; i<list.length; i++) {
	selectWindow(list[i]);
	print(list[i]);
  	row = 0;
  	//getHistogram(values, counts, 256); //for 8-bit images.
  	getHistogram(values, counts, nBins, 0, 2.2);//For 16-bit or 32-bit images
  	if (i == 0) {
  		for (x=0; x<nBins; x++) {
      		setResult("Value", row, values[x]);
      		setResult(list[i], row, counts[x]);
      		row++;
      	}
   } else {
  		for (x=0; x<nBins; x++) {
      		setResult(list[i], row, counts[x]);
      		row++;   	
   	}
  //updateResults();
  
 }
}
saveAs("Results", dir + "Histogram.csv");
