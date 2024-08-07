#!/bin/bash
#ref: https://wiki.biac.duke.edu/biac:fsl:guide

 

DATADIR=/Volumes/cerebro/Studies/VOGT/SENS/Public/Data/SENS_BIDS

label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with timestamp
########################################################################################################################################################################################################################

SUBJ="05" # (Next: 11, 12 for individual RUNs)
RUN="01" # for trial RUNs or individual RUNs

# for SUBJ in $(seq -f "%02g" 6 8) #set SUBJ number here for loops
# do
    # for RUN in $(seq -f "%02g" 1 2)
    # do
        
        if [ -d "${DATADIR}/sub-ID${SUBJ}" ]; then
############################################################################################################################################################################################################################################################ 
                echo Running SENS-${SUBJ} RUN${RUN}...
                date

               
                    echo "SENS ${SUBJ}_RUN${RUN} NOT warped..."

                    INPUT=${DIR}/filtered_func_data.nii.gz # change to example_func.nii.gz
                    OUTPUT=${DIR}/filtered_func_data_reg_wpd_v4.nii.gz 
                    printf "Functional Data Input: ${INPUT}\n"
                    
                    # defining i/o files
                    in_file=${DIR}/reg/highres2standard.nii.gz
                    affine_mat=${DIR}/reg/affine.mat # output from FLIRT linear registration here, not example_func2highres.mat
                    cout_mat=${DIR}/reg/non_lin_anat.mat
                    iout_file=${DIR}/reg/non_lin_anat.nii.gz
                    premat_mat=${DIR}/reg/premat_mat.mat
                    warp_mat=${DIR}/reg/non_lin_anat.mat

                    #LINEAR REGISTRATION
                    printf "Applying linear registration for MCA${SUBJ}_Ses${SES}_Mem${TASK} to MNI space..."
                    flirt --ref=${DIR}/reg/highres.nii.gz --in=${DIR}/reg/example_func.nii.gz --dof=6 --omat=${premat_mat}
                    flirt --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=${DIR}/reg/highres.nii.gz --omat=${affine_mat}
                    printf "Linear registration for MCA${SUBJ}_Ses${SES}_Mem${TASK} done...\n Starting FNIRT for MCA${SUBJ}_Ses${SES}_Mem${TASK}..."

                    #NON-LINEAR REGISTRATION
                    fnirt --in=${in_file} --ref=${FSLDIR}/data/standard/MNI152_T1_2mm  --aff=${affine_mat} --cout=${cout_mat} --iout=${iout_file} --warpres=8,8,8
                    printf "FNIRT warp for MCA${SUBJ}_Ses${SES}_Mem${TASK} done...\n"

                    #APPLY WARPS
                    printf "Applying warps for MCA${SUBJ}_Ses${SES}_Mem${TASK}..."
                    applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm  --in=${INPUT} --warp=${warp_mat} --premat=${premat_mat} --out=${OUTPUT}
                    printf "Warps applied for MCA${SUBJ}_Ses${SES}_Mem${TASK}...\n"

                    echo Registered MCA${SUBJ}_Ses${SES}_Mem${TASK} to MNI space. Warps applied for non-linear distortions.
                             
        else
            echo "SENS-${SUBJ} Data Not Available!"
        fi
#     done
# done