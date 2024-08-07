#!/bin/bash
# Run this script after running SENS_DCM2BIDS.sh (MRIcroGL's dicom to .nii conversion and dcm2bids conversion), and SENS_Func_BET_Processing.sh (for BET extraction)

# NOTES:
# 1. Fieldmap correction for Memory and Resting State: requires file datain_SENS.txt (contains param's)
# 2. Motion Correction, Outliers, and create Motion Confounds Matrix for GLM in First Level Preprocessing; note that the metric by default in the script is FD > 0.9 mm per email from 07-17-2024
# Reference: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLMotionOutliers
############################################################################################################################################################################################################################################################ 

DATADIR=/Volumes/cerebro/Studies/VOGT/SENS/Public/Data
datafile="${DATADIR}/FieldmapCorrectionFiles/datain_SENS.txt"

Subj="20" #set subj number here
# Run="02" #set session number here
############################################################################################################################################################################################################################################################ 

# for Subj in $(seq -f "%02g" 5 17) 
# do    
    for Run in $(seq -f "%02g" 1 2) 
    do
        
        if [ -d "${DATADIR}/SENS_BIDS/sub-ID${Subj}" ]; then
                echo Running SENS${Subj} Run${Run}
                date

                DERIV_DIR="${DATADIR}/SENS_BIDS/derivatives/sub-ID${Subj}"

                # make a directory for each subject in derivatives folder, if not already present
                if [ ! -d "${DATADIR}/SENS_BIDS/derivatives/sub-ID${Subj}/func" ] || [ ! -d "${DATADIR}/SENS_BIDS/derivatives/sub-ID${Subj}/fmap" ]; then
                    
                    mkdir -p ${DERIV_DIR}/func
                    mkdir -p ${DERIV_DIR}/fmap
                    # mkdir -p ${DERIV_DIR}/anat
                fi

                FIELDMAP_NAME_IN=${DATADIR}/SENS_BIDS/sub-ID${Subj}/fmap/sub-ID${Subj}
                FIELDMAP_NAME_OUT=${DERIV_DIR}/fmap/sub-ID${Subj}_run-${Run}_epi

                # MEM fieldmap correction
                # echo Starting Mem${Run} fieldmap correction...

                IMAGE_NAME_IN="${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold_brain"
                IMAGE_NAME_OUT="${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold_brain_corrected"

                fslmerge -t ${FIELDMAP_NAME_OUT}_merged ${FIELDMAP_NAME_IN}_dir-AP_run-${Run}_epi.nii.gz ${FIELDMAP_NAME_IN}_dir-PA_run-${Run}_epi.nii.gz
                topup --imain=${FIELDMAP_NAME_OUT}_merged --datain=${datafile} --config=b02b0.cnf --out=${FIELDMAP_NAME_OUT}_topup
                applytopup --imain=${IMAGE_NAME_IN} --method=jac --inindex=5 --datain=${datafile} --topup=${FIELDMAP_NAME_OUT}_topup --out=${IMAGE_NAME_OUT}
                wait
                
            
                NVOLS_M=$(fslnvols ${IMAGE_NAME_OUT})                             
                echo "Total volumes found: MEM Run${Run} - ${NVOLS_M}"
                # print the number of volumes in the functional data divided by 2
                NVOLS_M_HALF=$(echo "${NVOLS_M}/2" | bc) # middle volume for FNIRT registration
                echo Setting the mid volume for preprocessing func FNIRT registration: ${NVOLS_M_HALF}

                fslmaths ${IMAGE_NAME_OUT} ${IMAGE_NAME_OUT}_prefiltered -odt float

                fslroi ${IMAGE_NAME_OUT}_prefiltered ${IMAGE_NAME_OUT}_mid_func ${NVOLS_M_HALF} 1

                # Find motion spikes in MEM Data ; creates a confounds matrix for GLM in First Level Analysis ; changed to FD > 0.9 mm ; subjects 5 to 17 have fdrms results too
                echo Running motion calcs for SENS${Subj}_Mem${Run} ...
                fsl_motion_outliers -i ${IMAGE_NAME_OUT} -o ${IMAGE_NAME_OUT}_FD_confoundsMtx.txt -s ${IMAGE_NAME_OUT}_FD.txt -p ${IMAGE_NAME_OUT}_FD_plot.png --fd --thresh=0.9 --dummy=0 -v >> ${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold_FD_motion_log.txt  
                echo Motion calcs done for SENS${Subj}_Mem${Run}... See sub-ID${Subj}_task-mem_run-${Run}_bold_FD_motion_log.txt for detailed info!

                echo MEM${Run} done. 
                
                ##################################################################################
                # RS data fieldmap correction
                ##################################################################################

                echo Starting RS${Run} fieldmap correction...

                IMAGE_NAME_IN="${DERIV_DIR}/func/sub-ID${Subj}_task-rest_run-${Run}_bold_brain"
                IMAGE_NAME_OUT="${DERIV_DIR}/func/sub-ID${Subj}_task-rest_run-${Run}_bold_brain_corrected"

                applytopup --imain=${IMAGE_NAME_IN} --method=jac --inindex=5 --datain=${datafile} --topup=${FIELDMAP_NAME_OUT}_topup --out=${IMAGE_NAME_OUT}
                wait
                
                NVOLS_R=$(fslnvols ${IMAGE_NAME_OUT})                             
                echo "Total volumes found: RS Run${Run} - ${NVOLS_R}"

                # print the number of volumes in the functional data divided by 2
                NVOLS_R_HALF=$(echo "${NVOLS_R}/2" | bc)
                echo Setting the mid volume for preprocessing func FNIRT registration: ${NVOLS_R_HALF}

                fslmaths ${IMAGE_NAME_OUT} ${IMAGE_NAME_OUT}_prefiltered -odt float

                fslroi ${IMAGE_NAME_OUT}_prefiltered ${IMAGE_NAME_OUT}_mid_func ${NVOLS_R_HALF} 1

                # Find motion spikes in RS Data ; creates a confounds matrix for GLM in First Level Analysis
                echo Running motion calcs for SENS${Subj}_RS${Run} ...
                fsl_motion_outliers -i ${IMAGE_NAME_OUT} -o ${IMAGE_NAME_OUT}_FD_confoundsMtx.txt -s ${IMAGE_NAME_OUT}_FD.txt -p ${IMAGE_NAME_OUT}_FD_plot.png --fd --thresh=0.9 --dummy=0 -v >> ${DERIV_DIR}/func/sub-ID${Subj}_task-rest_run-${Run}_bold_FD_motion_log.txt
                
                echo Motion calcs done for SENS${Subj}_RS${Run}... See sub-ID${Subj}_task-rest_run-${Run}_bold_FD_motion_log.txt for detailed info!
                echo RS done. 

        else    
                echo Data not available for SENS${Subj}_${Run}
        fi
        
    done
# done

############################################################################################################################################################################################################################################################ 

echo Done! 
date