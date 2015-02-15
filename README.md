# gRAICAR: an exploratory tool for sub-group discovery in neuroimaging data

Author: Zhi Yang, Ph.D.

Institute of Psychology, Chinese Academy of Sciences

-
**To download this package, simply download the zip file (see the last button on the right sidebar) or clone the repository.**


## Release note
**Feb 15, 2015: Version 1.1**

- This version provides an option to perform ICA on individual subjects using RAICAR. Users can provide fMRI datasets and a group-level mask (both registered to standard space), and leave the ICA and gRAICAR work to the software.
- A few bug fixes.


**Jan 16, 2015: Version 1.0**

The first release of gRAICAR after a major reconstruction. 

Key features:

- A GUI to input file paths and parameters
- Automatically generate html reports
- Manage multi-core computation

## Documentation
Please see [_this tutorial_](tutorial/tutorial.md) for installing gRAICAR, running gRAICAR, and interpreting its outputs.

## Demonstration
An example dataset with 4 subjects is included in this repository, see the directory '_demo_'. 

This example shows recommended directory structure for gRAICAR analyses. Please refer to [a full directory tree](demo/directoryTree.txt) of the demonstration data.

Two configuration files, '_gRAICAR_settings_rest_MELODIC.mat_' and '_gRAICAR_settings_rest_RAICAR.mat_' are included in '_demo/0scripts/_'. These configuration files can be loaded using the GUI to run the example analysis.

Alternatively, the user can run the batch file, '_batch_setup_gRAICAR.m_' to perform the example analysis without using GUI.

The outputs of the demonstration are in '_demo/output_'. There are two versions of webpage reports, one for RAICAR mode, the other for MELODIC mode. Start browsing from '_demo/output/rest\_webreport_RAICAR/00index1.html_'.

## Reference
Please consider to cite the following publications:

**Original algorithms**

Yang Z, Zuo X, Wang P, Li Z, Laconte S, Bandettini PA, Hu X (2012). Generalized RAICAR: Discover homogeneous subject (sub)groups by reproducibility of their intrinsic connectivity networks. NeuroImage 63, 403-414

Yang Z, LaConte S, Weng X, and Hu X* (2008). Ranking and averaging independent component analysis by reproducibility (RAICAR). Human Brain Mapping 29, 711-25

**Improvements and applications**

Yang Z, Chang C, Xu T, Jiang L, Handwerker D, Castellanos F, Milham M, Bandettini P, Zuo X (2014). Connectivity Trajectory across Lifespan Differentiates the Precuneus from the Default Network. NeuroImage 89, 45-56.Yang Z, Xu Y, Xu T, Hoy C, Handwerker D, Chen G, Northoff G, Zuo X, Bandettini P (2014). Brain network informed subject community detection in early-onset schizophrenia. Scientific Reports 4, 5549.


