#!/bin/bash

# NOTE 1:  Based on confounds data available, edits template for SENS first level preprocessing and stats SENS_Mem_firstleveldesign_template_NOmpCON.fsf or SENS_Mem_firstleveldesign_template_mpCON.fsf in the DATADIR/Bash_Scripts_Templates director
# NOTE 2: For all subjects, T1w run-02 is used for anat file in the FEAT analysis, which is intensity-corrected and saved as the second run for each subject in BIDS format

########################################################################################## 

DATADIR=/Volumes/cerebro/Studies/VOGT/SENS/Public/Data


label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with timestamp



Subj=14
# Run=2


# for Subj in $(seq -f "%02g" 5 20)
# do
    for Run in $(seq -f "%02g" 1 2)
    do    
        DERIV_DIR=${DATADIR}/SENS_BIDS/derivatives/sub-ID${Subj}

            if [ -f "${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_bold.nii.gz" ]; then
                #print the file path to the console
                echo "Memory Data ${DATADIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold.nii.gz found..."
                PROCESSED=false
                for DIR in "${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_firstlevelstats_*.feat"; do
                    if [ -d "${DIR}" ]; then
                    # open ${DIR}/report_stats.html # for visual checks of the FEAT output    
                        echo "Memory Data sub-ID${Subj}_task-mem_run-${Run} already processed. Skipping to next FEAT..."
                        PROCESSED=true
                        break
                    fi
                done

                if [ "${PROCESSED}" = false ]; then
                    echo "Memory Data sub-ID${Subj}_task-mem_run-${Run} NOT processed..."
                    # checks for the scrubbed data, if not found, uses the corrected data from FirstLevel_DataPrep
                    if [ -f "${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold_brain_corrected_scrubbed.nii.gz" ]; then
                        INPUT=${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold_brain_corrected_scrubbed.nii.gz
                    else
                        INPUT=${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold_brain_corrected.nii.gz
                    fi                    

                    ANAT=${DERIV_DIR}/anat/sub-ID${Subj}_run-02_T1w_brain.nii.gz # run-02 T1w image used for registration , which is intensity-corrected and saved as the second run for each subject 
                    REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
                    CON_MTX=${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold_brain_corrected_FD_confoundsMtx.txt #confounds matrix from motion outliers

                    RK_EV=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_RK_events.tsv # "Remember/Know" words timing file 
                    echo ${RK_EV}
                    FGT_EV=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_FGT_events.tsv # "Forgot" words timing file
                    echo ${FGT_EV}
                    SHK_EV=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_SHK_events.tsv # "Shock" words timing file
                    echo ${SHK_EV}

                    OUTPUTDIR=${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_${label}
                    
                    echo "Memory Data ${INPUT} being processed..."
                        

                        if [ -f "$RK_EV" ] && [ -f "$FGT_EV" ] && [ -f "$SHK_EV" ]; then
                            
                            NVOLS=$(fslnvols ${INPUT}) # updates fsf file with number of vols/timepoints for the fmri run in this session-task from FSLNVOLS fslutil command
                            # save the number of volumes in the file from the first element of the array stored from $(fslstats ${INPUT})
                            NVXLS=$(fslstats ${INPUT} -V | awk '{print $1}') # updates fsf file with number of voxels for the fMRI run in this session-task from FSLSTATS command
                    
                            #replacing subject-specific task timing and motion parameters as EVs to the fsf file IF OUTLIERS WERE DETECTED
                            if [ -f "$CON_MTX" ]; then
                                echo "Found Motion Confounds Matrix for sub-${Subj}_task-mem_run-${Run}" 

                                for i in ${DATADIR}/Bash_Scripts_Templates/SENS_Mem_firstleveldesign_template_mpCON.fsf; do # finds marker/flags in the template fsf 
                                sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                                    -e 's@INPUT@'${INPUT}'@g' \
                                    -e 's@NVOLS@'${NVOLS}'@g' \
                                    -e 's@NVXLS@'${NVXLS}'@g' \
                                    -e 's@CON_MTX@'${CON_MTX}'@g' \
                                    -e 's@ANAT@'${ANAT}'@g' \
                                    -e 's@REGSTD@'${REGSTD}'@g' \
                                    -e 's@RK_EV@'${RK_EV}'@g' \
                                    -e 's@FGT_EV@'${FGT_EV}'@g' \
                                    -e 's@SHK_EV@'${SHK_EV}'@g' <$i> ${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_firstleveldesign.fsf

                                    # runs the FSL analysis using the newly created fsf file      
                                    echo "Running First Level Stats for sub-${Subj}_task-mem_run-${Run} ..."               
                                    feat ${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_firstleveldesign.fsf
                                    echo "First Level Stats for sub-${Subj}_task-mem_run-${Run} DONE"
                                        
                                done

                            else
                                echo "No Outliers in sub-${Subj}_task-mem_run-${Run}"   # if needed, can change motion outlier threshold in fsl_motion_outliers script for desired metric values
                                
                                for j in ${DATADIR}/Bash_Scripts_Templates/SENS_Mem_firstleveldesign_template_NOmpCON.fsf; do # finds marker/flags in the template fsf 
                                    sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                                        -e 's@INPUT@'${INPUT}'@g' \
                                        -e 's@NVOLS@'${NVOLS}'@g' \
                                        -e 's@NVXLS@'${NVXLS}'@g' \
                                        -e 's@ANAT@'${ANAT}'@g' \
                                        -e 's@REGSTD@'${REGSTD}'@g' \
                                        -e 's@RK_EV@'${RK_EV}'@g' \
                                        -e 's@FGT_EV@'${FGT_EV}'@g' \
                                        -e 's@SHK_EV@'${SHK_EV}'@g' <$j> ${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_firstleveldesign.fsf

                                        # runs the FSL analysis using the updated fsf file      
                                        echo "Running First Level Stats for sub-ID${Subj}_task-mem_run-${Run} with NO MOTION CONFOUNDS"               
                                        feat ${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_firstleveldesign.fsf
                                        echo "First Level Stats for sub-${Subj}_task-mem_run-${Run} DONE"
                                done
                            fi
                        else                  
                            echo "Events/Timing file not avaliable for sub-${Subj}_task-mem_run-${Run}"
                        fi
                else
                    echo "Memory Data sub-${Subj}_task-mem_run-${Run} already processed. Skipping to next run..."
                fi
            else 
                echo "Memory Data sub-${Subj}_task-mem_run-${Run} NOT found. Skipping to next run..."
            fi
    done
# done