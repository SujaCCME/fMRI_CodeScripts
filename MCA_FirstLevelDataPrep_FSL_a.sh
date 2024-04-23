#!/bin/bash
# Run from MCA study "Data" folder, after MRIcroGL's dicom to .nii conversion  - replicated copy of this script also here for simultaneous runs: ./MCA_FirstLevelDataPrep_FSL_b.sh
# Fieldmap correction for Memory, Pain, and Resting State: req's file = datain.txt (contains param's)
# As a QC, outputs total number of volumes in Mem1, Mem2, Pain, and RS scan
# BET brain extraction for Anatomical data
# Motion Correction, Outliers, and create Confound Matrix for GLM in First Level Preprocessing; note that the metric by default in the script is fdrms
# Reference: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLMotionOutliers

DATADIR=$PWD
Subj="35" #set subj number here # 43-1-1
# for Subj in {103..111}
# do
    Ses="1" #set session number here
    # for Ses in 1 2
    # do
        
        if [ -f "${DATADIR}/MCA${Subj}_Ses${Ses}/Original_data/FieldMap_SE_Memory_Part_1_AP_ph.nii.gz" ]; then
#################### Should not need to edit below this line ################ 
                echo Running MCA Subject ${Subj} Session ${Ses}
                date

                #Move all FieldMap files to sub-folder
                # mv ./MCA${Subj}_Ses${Ses}/Original_data/FieldMap*.nii.gz ./MCA${Subj}_Ses${Ses}/Original_data/Field_maps/ 

                #Mem1 fieldmap correction
                echo Starting Mem1 fieldmap correction...

                FIELDMAP_NAME="./MCA${Subj}_Ses${Ses}/Original_data/Field_maps/FieldMap_SE_Memory_Part_1"
                IMAGE_NAME_IN="./MCA${Subj}_Ses${Ses}/Original_data/Memory_Task_Part_1"
                IMAGE_NAME_OUT="./MCA${Subj}_Ses${Ses}/Mem1_func/MCA${Subj}_Ses${Ses}_Mem1"
                fslmerge -t ${FIELDMAP_NAME}_merged ${FIELDMAP_NAME}_AP.nii.gz ${FIELDMAP_NAME}_PA.nii.gz
                topup --imain=${FIELDMAP_NAME}_merged --datain=datain.txt --config=b02b0.cnf --out=${FIELDMAP_NAME}_topup
                applytopup --imain=${IMAGE_NAME_IN}.nii.gz --method=jac --inindex=5 --datain=datain.txt --topup=${FIELDMAP_NAME}_topup --out=${IMAGE_NAME_OUT}_corrected
                Wait
                #gunzip -k ./MCA${Subj}_Ses${Ses}/Mem1_func/MCA${Subj}_Ses${Ses}_Mem1_corrected.nii.gz
                
                NVOLS_M1=$(fslnvols ${IMAGE_NAME_OUT}_corrected.nii.gz)                             
                echo "Total volumes found: Mem1 - ${NVOLS_M1}"

                #Find motion spikes in Mem1 Data ; creates a confounds matrix for GLM in First Level Analysis
                echo Running motion calcs for MCA${Subj}_Ses${Ses}_Mem1...
                fsl_motion_outliers -i ${IMAGE_NAME_OUT}_corrected.nii.gz -o ${IMAGE_NAME_OUT}_mp-confoundsMtx.txt -s ${IMAGE_NAME_OUT}_fdrms.txt -p ${IMAGE_NAME_OUT}_fdrms_plot.png --fdrms --thresh=1.5 --dummy=0 -v
                

                echo Mem1 done. Starting Mem2...
                #Mem2 data

                FIELDMAP_NAME="./MCA${Subj}_Ses${Ses}/Original_data/Field_maps/FieldMap_SE_Memory_Part_2"
                IMAGE_NAME_IN="./MCA${Subj}_Ses${Ses}/Original_data/Memory_Task_Part_2"
                IMAGE_NAME_OUT="./MCA${Subj}_Ses${Ses}/Mem2_func/MCA${Subj}_Ses${Ses}_Mem2"
                fslmerge -t ${FIELDMAP_NAME}_merged ${FIELDMAP_NAME}_AP.nii.gz ${FIELDMAP_NAME}_PA.nii.gz
                topup --imain=${FIELDMAP_NAME}_merged --datain=datain.txt --config=b02b0.cnf --out=${FIELDMAP_NAME}_topup
                applytopup --imain=${IMAGE_NAME_IN}.nii.gz --method=jac --inindex=5 --datain=datain.txt --topup=${FIELDMAP_NAME}_topup --out=${IMAGE_NAME_OUT}_corrected
                Wait
                #gunzip -k ./MCA${Subj}_Ses${Ses}/Mem2_func/MCA${Subj}_Ses${Ses}_Mem2_corrected.nii.gz
                  
                NVOLS_M2=$(fslnvols ${IMAGE_NAME_OUT}_corrected.nii.gz)                             
                echo "Total volumes found: Mem2 - ${NVOLS_M2}"     

                #Find motion spikes in Mem2 Data ; creates a confounds matrix for GLM in First Level Analysis
                echo Running motion calcs: MCA${Subj}_Ses${Ses}_Mem2...
                fsl_motion_outliers -i ${IMAGE_NAME_OUT}_corrected.nii.gz -o ${IMAGE_NAME_OUT}_mp-confoundsMtx.txt -s ${IMAGE_NAME_OUT}_fdrms.txt -p ${IMAGE_NAME_OUT}_fdrms_plot.png --fdrms --thresh=1.5 --dummy=0 -v

                echo Mem2 done. Starting Pain...
                #Pain data

                FIELDMAP_NAME="./MCA${Subj}_Ses${Ses}/Original_data/Field_maps/FieldMap_SE_Pain"
                IMAGE_NAME_IN="./MCA${Subj}_Ses${Ses}/Original_data/Pain_Task"
                IMAGE_NAME_OUT="./MCA${Subj}_Ses${Ses}/Pain_func/MCA${Subj}_Ses${Ses}_Pain"
                fslmerge -t ${FIELDMAP_NAME}_merged ${FIELDMAP_NAME}_AP.nii.gz ${FIELDMAP_NAME}_PA.nii.gz
                topup --imain=${FIELDMAP_NAME}_merged --datain=datain.txt --config=b02b0.cnf --out=${FIELDMAP_NAME}_topup
                applytopup --imain=${IMAGE_NAME_IN}.nii.gz --method=jac --inindex=5 --datain=datain.txt --topup=${FIELDMAP_NAME}_topup --out=${IMAGE_NAME_OUT}_corrected
                Wait
                #gunzip -k ./MCA${Subj}_Ses${Ses}/Pain_func/MCA${Subj}_Ses${Ses}_Pain_corrected.nii.gz
                
                  
                NVOLS_P=$(fslnvols ${IMAGE_NAME_OUT}_corrected.nii.gz)                             
                echo "Total volumes found: Pain - ${NVOLS_P}"

                #Find motion spikes in Pain Data ; creates a confounds matrix for GLM in First Level Analysis
                echo Running motion calcs : MCA${Subj}_Ses${Ses} Pain data...
                fsl_motion_outliers -i ${IMAGE_NAME_OUT}_corrected.nii.gz -o ${IMAGE_NAME_OUT}_mp-confoundsMtx.txt -s ${IMAGE_NAME_OUT}_fdrms.txt -p ${IMAGE_NAME_OUT}_fdrms_plot.png --fdrms --thresh=1.5 --dummy=0 -v
                  
                echo Pain done. Starting Resting-state...
                
                #Resting-state data
                FIELDMAP_NAME="./MCA${Subj}_Ses${Ses}/Original_data/Field_maps/FieldMap_SE_Pain"
                IMAGE_NAME_IN="./MCA${Subj}_Ses${Ses}/Original_data/Resting_State"
                IMAGE_NAME_OUT="./MCA${Subj}_Ses${Ses}/Resting_state/MCA${Subj}_Ses${Ses}_RS"
                fslmerge -t ${FIELDMAP_NAME}_merged ${FIELDMAP_NAME}_AP.nii.gz ${FIELDMAP_NAME}_PA.nii.gz
                topup --imain=${FIELDMAP_NAME}_merged --datain=datain.txt --config=b02b0.cnf --out=${FIELDMAP_NAME}_topup
                applytopup --imain=${IMAGE_NAME_IN}.nii.gz --method=jac --inindex=5 --datain=datain.txt --topup=${FIELDMAP_NAME}_topup --out=${IMAGE_NAME_OUT}_corrected
                Wait
                # gunzip -k ./MCA${Subj}_Ses${Ses}/Resting_state/MCA${Subj}_Ses${Ses}_RS_corrected.nii.gz
                  
                NVOLS_R=$(fslnvols ${IMAGE_NAME_OUT}_corrected.nii.gz)                             
                echo "Total volumes found: Pain - ${NVOLS_R}"

                #Find motion spikes in RS Data ; creates a confounds matrix for GLM in First Level Analysis
                echo Running motion calcs : MCA${Subj}_Ses${Ses} RS data...
                fsl_motion_outliers -i ${IMAGE_NAME_OUT}_corrected.nii.gz -o ${IMAGE_NAME_OUT}_mp-confoundsMtx.txt -s ${IMAGE_NAME_OUT}_fdrms.txt -p ${IMAGE_NAME_OUT}_fdrms_plot.png --fdrms --thresh=1.5 --dummy=0 -v

                echo RS done. 
                echo Starting T1 Processing...

                # mkdir ./MCA${Subj}_Ses${Ses}/T1
                cp ./MCA${Subj}_Ses${Ses}/Original_data/T1w_MPRAGE_PA.nii.gz ./MCA${Subj}_Ses${Ses}/T1/MCA${Subj}_T1_anat.nii.gz
                # gunzip -k ./MCA${Subj}_Ses${Ses}/T1/MCA${Subj}_T1_anat.nii.gz     

                # BET extraction
                echo Running brain extraction with BET...
                bet ./MCA${Subj}_Ses${Ses}/T1/MCA${Subj}_T1_anat.nii.gz ./MCA${Subj}_Ses${Ses}/T1/MCA${Subj}_T1_anat_brain.nii.gz -R -f 0.3 -g 0.2 
                wait

                #FAST brain segmentation
                echo Running segmentation ...
                FAST -g ./MCA${Subj}_Ses${Ses}/T1/MCA${Subj}_T1_anat_brain.nii.gz
                wait
        else    
                echo Data not available for MCA${Subj}_${Ses}
        fi
        
#     done
# done
echo Done! 
date