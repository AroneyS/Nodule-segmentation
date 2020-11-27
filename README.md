# CelB-marked nodule segmentation and measurement

## Software required
- Fiji/ImageJ 2.0.0
- Fiji – IJPB-plugins (add through Updater)

## Before script
Stain gusA marked nodules and photograph on white background.
Crop images as tight as possible while including all nodules.

Train Weka Segmentation model on several training images.
Create two groups: nodules and background.
Draw on various places in the image that correspond to each group.
Save model and reload with separate image to repeat.

## ImageJ script (batch): imagej\_thresholding.ijm
Select a folder and run below on all files in it.

### 1. Weka segmentation (separate nodules vs background)
- Trainable Weka Segmentation – Plugins/Segmentation/Trainable Weka Segmentation
- Load classifier trained on nodules 
- Create result 
- Change to 8-bit (grayscale) – Image/Type/8-bit 

### 2. Thresholding
- Threshold – Image/Adjust/Threshold (light background, should highlight nodules in red) 
- Apply threshold 
- This image becomes a mask for the later watershed algorithm (leave open) 

### 3. Blurring 
- Return to Weka window and close to reopen original image 
- Split into colour channels – Image/Color/Split Channels 
- Use blue channel 
- Process/Filters/Gaussian Blur – Radius 3/8 (higher radius leads to less Watershed segmentation)

### 4. Watershed segmentation (separate side-by-side nodules)
Plugins/MorphoLibJ/Segmentation/Classic Watershed 
- Input: Gaussian blurred blue channel of cropped image 
- Mask: Output of Weka segmentation 
- Use diagonal connectivity 
- Min-Max: 0-255 
- Turn into mask: Image/Adjust/Threshold (set as 1-end) 

### 5. Analyse particles
Analyze/Analyze Particles 
- 100-Infinity Pixels^2 
- Show Outlines 
- Display results 