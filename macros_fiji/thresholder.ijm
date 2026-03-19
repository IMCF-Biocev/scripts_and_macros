dir = getDirectory("Directory path");
list = getList("image.titles");
if (list.length==0)
  print("No image windows are open.");
else {
  //print("Image windows are open."); 
  	print("\\Clear");
  	print("Group/Selection/Area/Parc_Area");
    }
m0 = m1 = m2 = m3 = m4 = m5 = m6 = m7 = m8 = m9 = m10 = m11 = m12 = m13 = m14 = t0 = t1 = t2 = t3 = t4 = t5 = t6 = t7 = t8 = t9 = t10 = t11 = t12 = t13 = t14 ="";
thresholds = newArray(0,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1,1.5); 
var_m = newArray(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14);
var_t = newArray(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14);

for (i=0; i<list.length; i++) {
	run("Clear Results");
	for (a=0; a<(thresholds.length-1); a++) {
		selectWindow(list[i]);
		run("Duplicate...", " ");
		setAutoThreshold("Default dark");
		//run("Threshold...");
		setThreshold(thresholds[a], thresholds[a+1]); // for sum
		run("Convert to Mask");
		var_m[a] =getTitle();
		}
	
	open(dir + "composite"+substring(list[i], 7, lengthOf(list[i])));
	run("8-bit");
	run("Z Project...", "projection=[Sum Slices]");
	setAutoThreshold("Default dark");
	//run("Threshold...");
	//setThreshold(35, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Size Opening 2D/3D", "min=200");
	rename("mask_"+list[i]);
	run("Erode");
	run("Erode");
	//run("Create Selection");
	run("Measure");
	run("Select None");
	run("Divide...", "value=255");

	for (b=0; b<(thresholds.length-1); b++) {
		imageCalculator("Multiply ", var_m[b],"mask_"+list[i]);
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Dilate");
		//run("Create Selection");
		run("Measure");
		}

	
	imageCalculator("Multiply ", list[i],"mask_"+list[i]);
	saveAs("Tiff", dir +"for-hist_"+list[i]+".tif");
	
	close("SUM_composite"+substring(list[i], 7, lengthOf(list[i])));
	selectWindow("mask_"+list[i]);
	run("Multiply...", "value=255.000");
	//close("mask_"+list[i]);
	close("composite"+substring(list[i], 7, lengthOf(list[i])));
	
	
	m = (getResult("IntDen", 0)/255);
	for (c=0; c<(thresholds.length-1); c++) {
		var_t[c] = (getResult("IntDen", c+1)/255);
		}
	
	print(list[i] + "/All/"+ m);
	for (d=0; d<(thresholds.length-1); d++) {
		print(list[i] + "/Threshold_"+thresholds[d]+"-"+thresholds[d+1]+"/"+var_t[d]+"/"+var_t[d]/m);
		}

	//run("Clear Results");
	
	
	
}

run("Tile");
