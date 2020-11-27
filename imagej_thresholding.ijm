/*
 * Macro template to process multiple images in a folder
 */

inPath = getDirectory("Input directory");

outPath = getDirectory("Output directory");

modelPath = File.openDialog("Choose the segmentation model");

suffix = ".tif";
outSuffix = ".csv";

processFolder(inPath);

function processFolder(inPath) {
	list = getFileList(inPath);
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], "/"))
			processFolder("" + inPath + list[i]);
		if(endsWith(list[i], suffix))
			processFile(inPath, outPath, list[i]);
	}
}

function processFile(inPath, outPath, file) {

	if (endsWith(file, suffix)){
		filename = substring(file, 0, lengthOf(file) - lengthOf(suffix));
	} else {
		filename = file;
	}

	open(inPath + filename + suffix);


	// Run segmentation into nodules and not-nodules based on specified classifier model
	run("Trainable Weka Segmentation");
	wait(3000);

	call("trainableSegmentation.Weka_Segmentation.loadClassifier", modelPath);
	call("trainableSegmentation.Weka_Segmentation.getResult");

	// Convert classified image into mask
	wait(3000);
	selectWindow("Classified image");
	run("8-bit");
	setAutoThreshold("Default");
	run("Threshold...");
	setThreshold(0, 120);
	setOption("BlackBackground", false);
	run("Convert to Mask");

	// Split original image channels
	open(inPath + filename + suffix);
	run("Split Channels");

	// Gaussian blur blue channel for less noisy watershed algorithm
	selectWindow(filename + "-1" + suffix + " (blue)");
	run("Gaussian Blur...", "sigma=8");

	// Run Classic Watershed to separate side-by-side nodules
	run("Classic Watershed", "input=[" + filename + "-1" + suffix + " (blue)] mask=[Classified image] use min=0 max=255");

	// Threshold watershed output and convert to mask for analysis
	selectWindow(filename + "-1-watershed" + suffix + " (blue)");
	setAutoThreshold("Default");
	run("Threshold...");
	setThreshold(1.0000, 1000000000000000000000000000000.0000);
	run("Convert to Mask");

	// Analyse particles and save results
	run("Analyze Particles...", "size=100-Infinity pixel show=Outlines display clear summarize");
	saveAs("Results", outPath + filename + outSuffix);

	//Closes all images
	run("Close All");
}
