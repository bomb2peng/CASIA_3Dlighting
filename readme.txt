Introduction:
This is the project for the paper "Optimized 3D Lighting Environment Estimation for Image Forgery Detection" by Bo Peng, Wei Wang, Jing Dong and Tieniu Tan, which is accepted for publication by IEEE Transaction on Information Forensics and Security (TIFS). This TIFS paper is extended from our WIFS 2015 conference paper "Improved 3D lighting environment estimation for image forgery detection" (http://ieeexplore.ieee.org/document/7368587/?reload=true&arnumber=7368587).

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
"TIFS_DSO_Morph.m" -- This file requires extra dependencies on Xiangyu Zhu's (http://www.cbsr.ia.ac.cn/users/xiangyuzhu) CVPR15 code (need modification) and the Basel Face Model.

Notes:
1. Results of ROC curves can change from time to time, because the selected 10,000 pairs are random. So you may get slightly different AUC results from the ones reported in the paper, but the differences should be small.
2. This is just crude academic experiment code. If you have any problem running the code, please report an issue on github. If you have questions about the algorithm, please drop me an email at bo dot peng at nlpr dot ia dot ac dot cn.