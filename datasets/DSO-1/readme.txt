In this folder are the results of our method on DSO-1, and the exact face pairs used for experiment in TIFS paper. In case you have problems with the dependencies and labours in reproducing, you may use these results for comparison.

"DSO_result.mat": the estimated lighting coefficients using Farid's method (LcoeffFaridMorph) and our proposesed (LcoeffFitGreyMorph).
"DSO-1_landmarks2.mat": the detected facial landmarks for all the images in DSO-1 dataset. Some faces cannot be detected. You may visualize the landmarks for each image by ploting. For each image, the landmarks is a 68x2xn array, where n is the number of detected faces.
"DSO-1_select2.txt": indicates which two faces are used in our experiment for each image. The indices can be looked up in "DSO-1_landmarks2.mat".

PS: you may run the "Compute the ROC curves" part in "TIFS_DSO_Morph.m" to plot the ROC curves.
