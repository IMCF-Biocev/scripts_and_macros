dir = getDirectory("Directory path");
list = getList("image.titles");
if (list.length==0)
  print("No image windows are open");
else {
    }
for (i=0; i<list.length; i++) {
	print("   "+list[i]);
	selectWindow(list[i]);
	run("Duplicate...", "duplicate");
	rename("max"+list[i]);
	run("Split Channels");
	close("C1-max"+list[i]);
	close("C5-max"+list[i]);
	
	selectWindow(list[i]);
	run("Split Channels");
	close("C1-"+list[i]);
	close("C5-"+list[i]);
	//waitForUser("Measure bg in channels");
	bg=5;
	//bg = getNumber("Define background value ch4:", 1);
	selectWindow("C4-"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Sum Slices]");
	run("Gaussian Blur...", "sigma=3");
	//run("Median...", "radius=3");
	//bg = getNumber("Define background value ch3:", 1);
	selectWindow("C3-"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Sum Slices]");
	run("Gaussian Blur...", "sigma=3");
	//run("Median...", "radius=3");
	//bg = getNumber("Define background value ch2:", 1);	
	selectWindow("C2-"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Sum Slices]");
	run("Gaussian Blur...", "sigma=3");
	//run("Median...", "radius=3");

	
	selectWindow("C4-max"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Max Intensity]");
	run("Median...", "radius=3");
	//bg = getNumber("Define background value ch3:", 1);
	selectWindow("C3-max"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Max Intensity]");
	run("Median...", "radius=3");
	//bg = getNumber("Define background value ch2:", 1);	
	selectWindow("C2-max"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Max Intensity]");
	run("Median...", "radius=3");
	run("Merge Channels...", "c1=[MAX_C4-max"+list[i]+"] c2=[MAX_C2-max"+list[i]+"] c3=[MAX_C3-max"+list[i]+"] create");
	saveAs("Tiff", dir+"composite-"+list[i]+".tif");
	imageCalculator("Divide create 32-bit", "SUM_C3-"+list[i],"SUM_C4-"+list[i]);
	//rename("C2divC4"+list[i]);
	saveAs("Tiff", dir+"C3divC4-"+list[i]+".tif");
	close("C2-"+list[i]);
	close("C3-"+list[i]);
	close("C4-"+list[i]);
	close("C2-max"+list[i]);
	close("C3-max"+list[i]);
	close("C4-max"+list[i]);	
	close("SUM_C2-"+list[i]);
	close("SUM_C3-"+list[i]);
	close("SUM_C4-"+list[i]);

  }
run("Tile");


