dir = getDirectory("Directory path");
list = getList("image.titles");
if (list.length==0)
  print("No image windows are open");
else {
    }
for (i=0; i<list.length; i++) {
	selectWindow(list[i]);
	saveAs("Tiff", dir+list[i]);
}

  
