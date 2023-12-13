//Bouton and Nuclei Batch Processing Macro by Sebastian Ho seh2232@cumc.columbia.edu (seho71@gmail.com)

//Comment this in to increase speed/out to decrease
setBatchMode(true);

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

//Choose where you want ROIs and Results to be saved
ROIDirectory = getDirectory("Choose ROI Directory");
ResultsDirectory = getDirectory("Choose Results Directory");

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	
open(input + File.separator + file);

//Necessary for Auto Save/Applying the correct process to designated channels
T = getTitle();
selectImage(T);
run("Split Channels");

//Nuclei Count Fxn
selectImage("C1-" + T);
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
run("Gaussian Blur...", "sigma=1.3 scaled");
run("Subtract Background...", "rolling=50");;
selectImage("C1-" + T);
run("Auto Threshold", "method=RenyiEntropy white");
run("Watershed");
run("Analyze Particles...", "size=0-infinity display add composite");

//Nuclei Count Auto-Save Nomenclature
roiManager("Save", ROIDirectory + T + "NucCt" + ".zip");
roiManager("Reset");
saveAs("Results", ResultsDirectory + T + "NucCt" + ".csv");
run("Clear Results");

//Bouton Count Fxn
selectImage("C2-" + T);
run("Subtract Background...", "rolling=12");
selectImage("C2-" + T);
run("Auto Threshold", "method=Otsu white");
run("Fill Holes");
run("Watershed");
run("Analyze Particles...", "size=1-Infinity pixel display add composite");

//Bouton Count Auto-Save Nomenclature
roiManager("Save", ROIDirectory + T + "BouCt" + ".zip");
roiManager("Reset");
saveAs("Results", ResultsDirectory + T + "BouCt" + ".csv");

//Reset
run("Clear Results");
run("Close All");
run("Collect Garbage");
}

