list = getList("image.titles");
if (list.length==0)
  print("No image windows are open");
else {
  print("Image windows:"); 
    }
for (i=0; i<list.length; i++) {
	print("   "+list[i]);
	selectWindow(list[i]);
	//run("Duplicate...", "duplicate");
	run("Split Channels");
	close("C1-"+list[i]);
	close("C5-"+list[i]);
	run("Tile");
	//waitForUser("Measure bg in channels");
	bg=5;
	//bg = getNumber("Define background value ch4:", 1);
	selectWindow("C4-"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Average Intensity]");
	//run("Gaussian Blur...", "sigma=3");
	//bg = getNumber("Define background value ch3:", 1);
	selectWindow("C3-"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Average Intensity]");
	//run("Gaussian Blur...", "sigma=3");
	//bg = getNumber("Define background value ch2:", 1);	
	selectWindow("C2-"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Average Intensity]");
	//run("Gaussian Blur...", "sigma=3");
	//run("Duplicate...", " ");
	run("Merge Channels...", "c1=[AVG_C4-"+list[i]+"] c2=[AVG_C2-"+list[i]+"] c3=[AVG_C3-"+list[i]+"] create keep");
	saveAs("Tiff", "C:/Users/zuzka/Desktop/rasy/processed/"+"composite-"+list[i]+".tif");
	//run("Channels Tool...");
	Stack.setActiveChannels("111");
//setAutoThreshold("Default dark");
//run("Threshold...");
//setOption("BlackBackground", false);
//run("Convert to Mask");

//run("Close");
//run("Create Selection");
	//roiManager("Add");
//roiManager("Select", 0);
	//imageCalculator("Add create", "AVG_C2-"+list[i],"AVG_C3-"+list[i]);
	//selectWindow("Result of AVG_C2-"+list[i]);
	//rename("SUM_C2C3-"+list[i]);
	imageCalculator("Divide create 32-bit", "AVG_C2-"+list[i],"AVG_C4-"+list[i]);
	rename("C2divC4"+list[i]);
	//saveAs("Tiff", "C:/Users/zuzka/Desktop/rasy/processed/"+"C2divC4-"+list[i]+".tif");
	//imageCalculator("Divide create 32-bit", "SUM_C3-"+list[i],"SUM_C4-"+list[i]);
	//rename("C3divC4");
	//imageCalculator("Divide create 32-bit", "SUM_C2C3-"+list[i],"AVG_C4-"+list[i]);
	//rename("C2C3divC4"+list[i]);
	//saveAs("Tiff", "C:/Users/zuzka/Desktop/rasy/processed/"+"C2C3divC4-"+list[i]+".tif");
	//imageCalculator("Add create", "AVG_C2-"+list[i],"AVG_C4-"+list[i]);
	//rename("SUM_C2C4-"+list[i]);
	//imageCalculator("Divide create 32-bit", "AVG_C2-"+list[i],"SUM_C2C4-"+list[i]);
	//rename("Percentage_C2_of_C2C4-"+list[i]);
	//saveAs("Tiff", "C:/Users/zuzka/Desktop/rasy/processed/"+"Percentage_C2_of_C2C4-"+list[i]+".tif");
	//imageCalculator("Add create", "AVG_C3-"+list[i],"SUM_C2C4-"+list[i]);
	//rename("SUM_C2C3C4-"+list[i]);
	//imageCalculator("Divide create 32-bit", "AVG_C2-"+list[i],"SUM_C2C3C4-"+list[i]);
	//rename("Percentage_C2_of_C2C3C4-"+list[i]);
	//saveAs("Tiff", "C:/Users/zuzka/Desktop/rasy/processed/"+"Percentage_C2_of_C2C3C4-"+list[i]+".tif");
	close("C2-"+list[i]);
	close("C3-"+list[i]);
	close("C4-"+list[i]);
	//close("AVG_C2-"+list[i]);
	//close("AVG_C3-"+list[i]);
	//close("AVG_C4-"+list[i]);
	//close("SUM_C2C3-"+list[i]);
	//close("SUM_C2C4-"+list[i]);
	//close("SUM_C2C3C4-"+list[i]);

  }
run("Tile");


