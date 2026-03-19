dir = getDirectory("Directory path");
list = getList("image.titles");
if (list.length==0)
  print("No image windows are open");
else {
    }
for (i=0; i<list.length; i++) {
	selectWindow(list[i]);
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
	run("Gaussian Blur...", "sigma=3");
	//bg = getNumber("Define background value ch3:", 1);
	selectWindow("C3-"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Average Intensity]");
	run("Gaussian Blur...", "sigma=3");
	//bg = getNumber("Define background value ch2:", 1);	
	selectWindow("C2-"+list[i]);
	run("Subtract...", "value="+bg);
	run("Z Project...", "projection=[Average Intensity]");
	run("Gaussian Blur...", "sigma=3");
	//run("Duplicate...", " ");
	run("Merge Channels...", "c1=[AVG_C4-"+list[i]+"] c2=[AVG_C2-"+list[i]+"] c3=[AVG_C3-"+list[i]+"] create keep");
	saveAs("Tiff", dir +"composite-"+list[i]+".tif");
	imageCalculator("Divide create 32-bit", "AVG_C2-"+list[i],"AVG_C4-"+list[i]);
	rename("C2divC4"+list[i]);
	saveAs("Tiff", dir+"C2divC4-"+list[i]+".tif");
	close("C2-"+list[i]);
	close("C3-"+list[i]);
	close("C4-"+list[i]);

  }
run("Tile");


