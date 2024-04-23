 #!/bin/bash
#ref: https://wiki.biac.duke.edu/biac:fsl:guide

######### run this preprocessing script from MCA_FMRI/Public/Data directory; 

#loads the fsl program
#export FSLDIR=/usr/local/packages/fsl
#.${FSLDIR}/etc/fslconf/fsl.sh
 

#DATADIR=/Volumes/cerebro/Studies/MCA_FMRI/Public/Data
DATADIR=$PWD
label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with timestamp
########################################################################################################################################################################################################################
 
# FEAT precessing check for each subject, session, and task

# SUBJ=8 # (Next: 43-1-2, 34)
# SES=1 # for trial runs or individual runs
# TASK=1 # for trial runs or individual runs

for SUBJ in {7..116}
do
    for SES in 1 2 
    do
        for TASK in 1 2
        do
            if [ -f "${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_corrected.nii.gz" ]; then
                PROCESSED=false
                for DIR in "${DATADIR}/FSL_Mem/First_Level_Subj_Analyses/${SUBJ}-${SES}-m${TASK}_Pre_"*_*.feat; do
                    if [ -d "${DIR}" ]; then
                        # open ${DIR}/report.html # for visual checks of the FEAT output    
                        echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} already processed. Skipping to next FEAT..."
                        PROCESSED=true
                        break
                    fi
                done

                if [ "${PROCESSED}" = false ]; then
                    echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} NOT processed..."
                    # checks for the scrubbed data, if not found, uses the corrected data from FirstLevel DataPrep
                    if [ -f "${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_corrected_scrubbed.nii.gz" ]; then
                        INPUT=${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_corrected_scrubbed.nii.gz
                    else
                        INPUT=${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_corrected.nii.gz
                    fi
                    NVOLS=$(fslnvols ${INPUT}) # updates fsf file with number of vols/timepoints for the fmri run in this session-task from FSLNVOLS fslutil command
                    # save the number of volumes in the file from the first element of the array stored from $(fslstats ${INPUT})
                    NVXLS=$(fslstats ${INPUT} -V | awk '{print $1}') # updates fsf file with number of voxels for the fmri run in this session-task from FSLSTATS command
                    ANAT=${DATADIR}/MCA${SUBJ}_Ses${SES}/T1/MCA${SUBJ}_T1_anat_brain.nii.gz
                    REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
                    CON_MTX=${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_mp-confoundsMtx.txt #confounds matrix from motion outliers
                    RK_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_RorK_words_FSL.txt # "Remember/Know" words timing file
                    FGT_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_SF_words.txt # "Forgot" words timing file
                    SHK_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_shock_timings.txt # "Shock" words timing file
                    OUTPUTDIR=${DATADIR}/FSL_Mem/First_Level_Subj_Analyses/${SUBJ}-${SES}-m${TASK}_Pre_${label}
                    
                    echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} being processed..."
                        
                        # checks if the timing files are available for the subject, session, and task                           
                        if [ ! -f "$RK_EV" ] && [ ! -f "$FGT_EV" ] && [ ! -f "$SHK_EV" ]; then
                        # moving txt files to the FSL_Mem directory for EV input to the fsf file
                        mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_RorK_words_FSL.txt ${RK_EV}
                        mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_SF_words.txt ${FGT_EV}
                        mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_shock_timings.txt ${SHK_EV}
                        fi

                        if [ -f "$RK_EV" ] && [ -f "$FGT_EV" ] && [ -f "$SHK_EV" ]; then
                            #replacing subject-specific task timing and motion parameters as EVs to the fsf file IF OUTLIERS WERE DETECTED
                            if [ -f "$CON_MTX" ]; then
                                echo "Found Motion Confounds Matrix for MCA${SUBJ}_Ses${SES}_Mem${TASK}" 

                                for i in 'MCA_Mem_firstleveldesign_template_mpCON_oacV.fsf'; do # finds marker/flags in the template fsf 
                                sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                                    -e 's@INPUT@'${INPUT}'@g' \
                                    -e 's@NVOLS@'${NVOLS}'@g' \
                                    -e 's@NVXLS@'${NVXLS}'@g' \
                                    -e 's@CON_MTX@'${CON_MTX}'@g' \
                                    -e 's@ANAT@'${ANAT}'@g' \
                                    -e 's@REGSTD@'${REGSTD}'@g' \
                                    -e 's@RK_EV@'${RK_EV}'@g' \
                                    -e 's@FGT_EV@'${FGT_EV}'@g' \
                                    -e 's@SHK_EV@'${SHK_EV}'@g' <$i> ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstleveldesign.fsf

                                    #runs the FSL analysis using the newly created fsf file                        
                                        if [ -f "$RK_EV" ]; then #check interchangeably w FGT_EV and SHK_EV
                                        echo "Running First Level Stats for MCA${SUBJ}_Ses${SES}_Mem${TASK} ..."               
                                        feat ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstleveldesign.fsf
                                        else 
                                        echo "Timing file not avaliable for MCA${SUBJ}_Ses${SES}_Mem${TASK}"
                                        fi
                                done

                            else
                                echo "No Outliers in MCA${SUBJ}_Ses${SES}_Mem${TASK}"   # if needed, can change motion outlier threshold in fsl_motion_outliers script for desired metric values
                                
                                for j in 'MCA_Mem_firstleveldesign_template_NOmpCON_oacV.fsf'; do # finds marker/flags in the template fsf 
                                    sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                                        -e 's@INPUT@'${INPUT}'@g' \
                                        -e 's@NVOLS@'${NVOLS}'@g' \
                                        -e 's@NVXLS@'${NVXLS}'@g' \
                                        -e 's@ANAT@'${ANAT}'@g' \
                                        -e 's@REGSTD@'${REGSTD}'@g' \
                                        -e 's@RK_EV@'${RK_EV}'@g' \
                                        -e 's@FGT_EV@'${FGT_EV}'@g' \
                                        -e 's@SHK_EV@'${SHK_EV}'@g' <$j> ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstleveldesign.fsf

                                        #runs the FSL analysis using the updated fsf file      
                                        echo "Running First Level Stats for MCA${SUBJ}_Ses${SES}_Mem${TASK} with NO MOTION CONFOUNDS"               
                                        feat ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstleveldesign.fsf

                                done

                            fi
                        else                  
                            echo "Timing file not avaliable for MCA${SUBJ}_Ses${SES}_Mem${TASK}"
                        fi
                else
                    echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} already processed. Skipping to next run..."
                fi
            else 
                echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} NOT found. Skipping to next run..."
            fi
        done
    done
done