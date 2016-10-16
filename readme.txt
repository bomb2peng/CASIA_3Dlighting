Introduction:
This is the project for the under-review TIFS paper "Optimized 3D Lighting Environment Estimation for Image Forgery Detection" by Bo Peng, Wei Wang, Jing Dong and Tieniu Tan.

Terms of use:
1. The code and algorithm in this project are for non-commercial use only.
2. If you use the code in your own project, please cite our paper.

Dependencies:
1. toolbox_graph: http://cn.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph/content/toolbox_graph/html/content.html

Optional Dependencies:
1. FaceGen Modeller -- to generate new 3D face models.
2. pbrt v2 -- to render synthetic images and calculate Spherical Harmonics coefficients for known lighting (need modification of pbrt).
3. IntraFace Matlab functions (or other facial landmark detectors) -- to detect facial landmarks.

Datasets:
We have included in this repository our Syn1 and Syn2 datasets. You have to download or apply for the following datasets by your own:
1. YaleB
2. Multi-PIE
3. Carvalho's DSO-1

How to run:
1. Modify the "setPath.m" using your own specific file directories, then run it.
2. To reproduce the results reported in the paper, run the following files in Matlab:
"TIFS_Syn1_FaceGen.m"
"TIFS_Syn2_FaceGen.m"
"TIFS_YaleB_FaceGen.m"
"TIFS_MultiPIE_FaceGen.m"
"TIFS_DSO_Morph.m" -- The file is not supported for now, because of copyright concerns. It requires modified code from Xiangyu Zhu's CVPR15 paper and also the Basel Face Model.

Notes:
1. Results of ROC curves can change from time to time, because the selected 10,000 pairs are random. So you may get slightly different AUC results from the ones reported in the paper, but the differences should be small.
2. This is just crude academic experiment code. If you have any problem running the code, please report an issue on github. If you have questions about the algorithm, please drop me an email at bo dot peng at nlpr dot ia dot ac dot cn.