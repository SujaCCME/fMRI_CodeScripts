#!/bin/bash
#ref: https://wiki.biac.duke.edu/biac:fsl:guide


DATADIR=/Volumes/cerebro/Studies/VOGT/SENS/Public/Data/SENS_BIDS

label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with timestamp
########################################################################################################################################################################################################################

SUBJ="17" # (Next: 11, 12 for individual RUNs)
RUN="01" # for trial RUNs or individual RUNs

# for SUBJ in $(seq -f "%02g" 6 8) #set SUBJ number here for loops
# do
    # for RUN in $(seq -f "%02g" 1 2)
    # do 
        if [ -d "${DATADIR}/sub-ID${SUBJ}" ]; then
############################################################################################################################################################################################################################################################ 
                echo Running SENS-${SUBJ} RUN${RUN}...
                date


                for DIR in "${DATADIR}/derivatives/sub-ID${SUBJ}/func/sub-ID${SUBJ}_task-mem_run-${RUN}"_*_*_v2.feat; do   # delete v2 after reg-warp trials
                    printf "Checking for ${DIR}...\n"      
                    if [ -f "${DIR}/filtered_func_data_reg_wpd.nii.gz" ]; then
                        echo "SENS ${SUBJ}_RUN${RUN} already warped..."
                        
                    else
                        echo "SENS ${SUBJ}_RUN${RUN} NOT warped..."

                        INPUT=${DIR}/filtered_func_data.nii.gz
                        OUTPUT=${DIR}/filtered_func_data_reg_wpd.nii.gz 
                        printf "Functional Registered Data Input: ${INPUT}\n"
                        
                        # defining i/o files
                        in_file=${DIR}/reg/highres.nii.gz
                        affine_mat=${DIR}/reg/highres2standard.mat 
                        iout_file=${DIR}/reg/non_lin_highres.nii.gz
                        premat_mat=${DIR}/reg/example_func2highres.mat
                        warp_mat=${DIR}/reg/non_lin_highres.mat

                        #LINEAR REGISTRATION
                        # printf "Applying linear registration for MCA${SUBJ}_Ses${SES}_Mem${TASK} to MNI space..."
                        # flirt --ref=${DIR}/reg/highres.nii.gz --in=${DIR}/reg/example_func.nii.gz --dof=6 --omat=${premat_mat}
                        # flirt --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=${DIR}/reg/highres.nii.gz --omat=${affine_mat}
                        printf "Linear registration for MCA${SUBJ}_Ses${SES}_Mem${TASK} done...\n Starting FNIRT for MCA${SUBJ}_Ses${SES}_Mem${TASK}..."

                        #NON-LINEAR REGISTRATION
                        fnirt --in=${in_file} --ref=${FSLDIR}/data/standard/MNI152_T1_2mm  --aff=${affine_mat} --cout=${warp_mat} --iout=${iout_file} --warpres=8,8,8
                        printf "\n FNIRT warp for Anat MCA${SUBJ}_Ses${SES}_Mem${TASK} done...\n"

                        #APPLY WARPS
                        printf "Applying warps for Func MCA${SUBJ}_Ses${SES}_Mem${TASK}...\n"
                        applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm  --in=${INPUT} --warp=${warp_mat} --premat=${premat_mat} --out=${OUTPUT}
                        printf "Warps applied for MCA${SUBJ}_Ses${SES}_Mem${TASK}...\n"

                        echo Registered MCA${SUBJ}_Ses${SES}_Mem${TASK} to MNI space. Warps applied for non-linear distortions.
                    fi 
                done       
        else
            echo "SENS-${SUBJ} Data Not Available!"
        fi
#  done
# done