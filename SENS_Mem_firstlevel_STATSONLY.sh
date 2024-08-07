#!/bin/bash
#ref: https://wiki.biac.duke.edu/biac:fsl:guide
########################################################################################################################################################################################################################

# Note that _trial is appended for the trial i/o files to avoid overwriting the original files
 
DATADIR=/Volumes/cerebro/Studies/VOGT/SENS/Public/Data

label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with timestamp
########################################################################################################################################################################################################################

# FEAT precessing check for each subject, session, and task

Subj=14
# Run=2


# for Subj in $(seq -f "%02g" 5 20)
# do
    for Run in $(seq -f "%02g" 1 2)
    do    
        DERIV_DIR=${DATADIR}/SENS_BIDS/derivatives/sub-ID${Subj}

        if [ -f "${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_bold.nii.gz" ]; then
        #print the file path to the console
        echo "Original Data ${DATADIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold.nii.gz found..."
        PROCESSED=false      
            for DIR in "${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}"_*_*.feat; do
                if [ -d "${DIR}/sub-ID${Subj}_task-mem_run-${Run}_StatsOnly.feat" ]; then
                    # open ${DIR}/sub-ID${Subj}_task-mem_run-${Run}_StatsOnlu.feat/report_stats.html
                    echo "Memory Data sub-ID${Subj}_task-mem_run-${Run} already processed with full confounds set. Skipping to next FEAT..."
                    PROCESSED=true                                   
                    break
                fi
                
                if [ "${PROCESSED}" = false ]; then
                    echo "Memory Data sub-ID${Subj}_task-mem_run-${Run} NOT processed with full confounds..."

                    INPUT=${DIR}/filtered_func_data_reg.nii.gz 
                    printf "Registered Functional Data Input: ${INPUT}\n"

                    NVOLS=$(fslnvols ${INPUT}) # updates fsf file with number of vols/timepoints for the fmri run in this session-task from FSLNVOLS fslutil command
                    NVXLS=$(fslstats ${INPUT} -V | awk '{print $1}') # updates fsf file with number of voxels for the fmri run in this session-task from FSLSTATS command; the first element of the array stored from $(fslstats ${INPUT})
                    REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
                    CON_MTX=${DIR}/filtered_func_data_reg_mp6_FD_CmCrn5.txt #confounds matrix from motion parameters, motion outliers FD>0.9mm, n=5 CompCor WM and CSF
                    
                    RK_EV=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_RK_events.tsv # "Remember/Know" words timing file
                    #print $RK_EV    
                    echo ${RK_EV}
                    FGT_EV=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_FGT_events.tsv # "Forgot" words timing file
                    echo ${FGT_EV}
                    SHK_EV=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_SHK_events.tsv # "Shock" words timing file
                    echo ${SHK_EV}
                    
                    OUTPUTDIR=${DIR}/sub-ID${Subj}_task-mem_run-${Run}_StatsOnly.feat
                    
                    echo "Memory Data sub-ID${Subj}_task-mem_run-${Run} being processed..."
                    
                    if [ -f "$RK_EV" ] && [ -f "$FGT_EV" ] && [ -f "$SHK_EV" ]; then
                            #replacing subject-specific task timing and motion parameters as EVs to the fsf file IF OUTLIERS WERE DETECTED
                            if [ -f "$CON_MTX" ]; then
                                echo "Found Confounds Matrix For Subject: sub-ID${Subj}_task-mem_run-${Run}" 

                                for i in ${DATADIR}/Bash_Scripts_Templates/SENS_Mem_firstlevel_STATSONLY_design_template.fsf; do # finds marker/flags in the template fsf; do 
                                    sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                                        -e 's@INPUT@'${INPUT}'@g' \
                                        -e 's@NVOLS@'${NVOLS}'@g' \
                                        -e 's@NVXLS@'${NVXLS}'@g' \
                                        -e 's@CON_MTX@'${CON_MTX}'@g' \
                                        -e 's@REGSTD@'${REGSTD}'@g' \
                                        -e 's@SHK_EV@'${SHK_EV}'@g' \
                                        -e 's@RK_EV@'${RK_EV}'@g' \
                                        -e 's@FGT_EV@'${FGT_EV}'@g' <$i> ${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_firstlevel_STATSONLY_design.fsf
                                        
                                        # runs the FSL analysis using the newly created fsf file                                                                  
                                        echo "Running First Level Stats for sub-ID${Subj}_task-mem_run-${Run} with full confound set..."            
                                        feat ${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_firstlevel_STATSONLY_design.fsf
                                        echo "Memory Data sub-ID${Subj}_task-mem_run-${Run} processed with full confound set."                                                
                                    done                                           
                            else
                                echo "Confounds set missing for subject: sub-ID${Subj}_task-mem_run-${Run}"   
                                echo "${DIR} full confound set NOT processed . Skipping to next run..."
                            fi
                    else
                            echo "Events/Timing file not avaliable: MCA${SUBJ}_Ses${SES}_Mem${TASK}"
                    fi
                else
                    echo "Memory Data sub-ID${Subj}_task-mem_run-${Run} already processed. Skipping to next run..."
                fi
            done 

        else 
            echo Memory Data sub-ID${Subj}_task-mem_run-${Run} NOT found. Skipping to next run...
        fi    
    done
# done