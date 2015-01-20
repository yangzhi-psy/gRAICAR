# Recommendations for performing ICA, normalizing component maps, and generating group-level mask


## ICA

The _MELODIC_ module in [_FSL_] (www.fmrib.ox.ac.uk/fsl)  or [_FastICA_] (research.ics.aalto.fi/ica/fastica/) package for MATLAB can be used to perform ICA analyses for individual subjects.

### _MELODIC_
Here is an example command for _melodic_:

```bash
melodic -i bp_filtered.nii.gz --outdir=tmp.ica --mask=gms_mask.nii.gz --nobet --no_mm --Oorig -v
```

The '_bp\_filtered.nii.gz_' is a preprocessed functional dataset; the '_tmp.ica_' is the output directory; the '_gms_mask.nii.gz_' is a mask file.

This command will call _MELODIC_ to automatically estimate the number of components and perform ICA.

This command can be called in a loop structure to perform ICA for all individuals.

In the output directory, the ICA component maps are in '_melodic\_IC.nii.gz_'.

### _FastICA_
todo

## Spatial normalization

**The quality of the spatial normalization is an important factor affecting the gRAICAR results. Please check the normalization quality carefully.**


Here is an example command for normalizing the ICA component maps from _MELODIC_:

```bash
applywarp --ref=${standard_template} --in=melodic_IC.nii.gz --out=melodic_IC_mni152_3mm.nii.gz --warp=${anat_reg_dir}/highres2standard_warp.nii.gz --premat=${func_reg_dir}/example_func2highres.mat
```

The '_${standard\_template}_' is a standard template to register to. A template file that the author usually used (NMI space, 3mm resolution) can be downloaded [here] ().

The '_melodic\_IC.nii.gz_' is the output from _MELODIC_

The '_${anat\_reg\_dir}/highres2standard\_warp.nii.gz_' is a warp file containing non-learning transformations from the high-resolution T1 image of the subject to the standard space. This file can be obtained using _FNIRT_ in _FSL_ or other co-registration methods (e.g., ANTS).

The '_${func\_reg\_dir}/example\_func2highres.mat_' is a tranformation matrix from functional images to the high-resolution T1 image of the subject.

This command will integrate two transformations and co-register the ICA component maps to the standard template.

Like the _MELODIC_ command, this _applywarp_ command can be looped through all subjects.

## Group-level mask

Brain masks of individual subjects should be spatially normalized before generating group-level mask. Please refer to the _applywarp_ command for normalizing individual masks.

The following command can be used to make group-level mask from normalized individual masks:

```bash
for subj in `cat subjects.list`
do
	fslmaths mask_grp.nii.gz -mul mask_${subj}.nii.gz -bin mask_grp.nii.gz
done
```


