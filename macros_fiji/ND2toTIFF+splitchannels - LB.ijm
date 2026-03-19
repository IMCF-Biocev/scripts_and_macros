// select folder and open files
run("Close All")
folder = getDirectory("Choose_Images_Directory");
folderOUT = getDirectory("Choose_Output_Directory"); 
list = getFileList(folder); 
run("Clear Results");
setBatchMode(true); 

for (i=0; i < list.length; i++) { 
	if (endsWith(list[i], ".nd2")) {
		path = folder+list[i]; 	
		//run("Bio-Formats Importer", "open=path open_all_series view=Hyperstack stack_order=XYCZT");
		run("Bio-Formats Importer", "open=path color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack");
		title = getTitle();
		filename = split(title, ".");
				
		selectImage(title);
		makeRectangle(1, 0, 246, 512);
		run("Duplicate...", "duplicate");
		//run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		left_file = folderOUT+filename[0] +"_left.tif";
		run("Bio-Formats Exporter", "save="+ left_file + " export compression=Uncompressed");
		close();
		
		selectImage(title);
		makeRectangle(258, 0, 246, 512);
		run("Duplicate...", "duplicate");
		//run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		right_file = folderOUT+filename[0] +"_right.tif";
		run("Bio-Formats Exporter", "save="+ right_file + " export compression=Uncompressed");
		//close();
		
		selectImage(title);
		whole_file = folderOUT+filename[0] +"_whole.tif";
		run("Bio-Formats Exporter", "save=" + whole_file + " export compression=Uncompressed");
		run("Close All");

	}
}