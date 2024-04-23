#!/bin/bash
#ref: https://wiki.biac.duke.edu/biac:fsl:guide

######### run this preprocessing script from MCA_FMRI/Public/Data directory; 
# Based on confounds data available, edits template  MCA_Mem_firstleveldesign_template_mpCON_oacKV.fsf or MCA_Mem_firstleveldesign_template_NOmpCON_oacV.fsf from Data folder to do subject specific GLM design


#loads the fsl program
#export FSLDIR=/usr/local/packages/fsl
#.${FSLDIR}/etc/fslconf/fsl.sh
 

#DATADIR=/Volumes/cerebro/Studies/MCA_FMRI/Public/Data
DATADIR=$PWD
label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with timestamp
########################################################################################################################################################################################################################
 
#makes the compounded GLM design first-level FEAT file
SUBJ=111 # (Next: 43-1-2, 34)
# SES=2 # for trial runs or individual runs
# TASK=1 # for trial runs or individual runs

# for SUBJ in {7..8}
# do
    for SES in 1 2 
    do
        for TASK in 1 2 # no TASK loop for Pain; Pain code separately written from Memory Preprocessing--see MCA_Subj_Level_PainPrePro+Stats_FSL_oacV.sh
        do
                 
                if [ -f "${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_corrected.nii.gz" ]; then
                
                    INPUT=${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_corrected.nii.gz
                    NVOLS=$(fslnvols ${INPUT}) # updates fsf file with number of vols/timepoints for the fmri run in this session-task from FSLNVOLS fslutil command
                    ANAT=${DATADIR}/MCA${SUBJ}_Ses${SES}/T1/MCA${SUBJ}_T1_anat_brain.nii.gz
                    REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
                    CON_MTX=${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_mp-confoundsMtx.txt #confounds matrix from motion outliers
                    RK_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_RorK_words_FSL.txt # "Remember/Know" words timing file
                    FGT_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_SF_words.txt # "Forgot" words timing file
                    SHK_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_shock_timings.txt # "Shock" words timing file
                    OUTPUTDIR=${DATADIR}/FSL_Mem/First_Level_Subj_Analyses/${SUBJ}-${SES}-m${TASK}_Pre_${label}

                    if [ -d "${DATADIR}/FSL_Mem/First_Level_Subj_Analyses/${SUBJ}-${SES}-m${TASK}_Pre_"*.feat ]; then  #checks if the output directory already exists
                        echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} already processed. Skipping to next run..."  
                        continue;
                    else
                        echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} being processed..."
                        # moving txt files to the FSL_Mem directory for EV input to the fsf file
                        mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_RorK_words_FSL.txt ${RK_EV}
                        mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_SF_words.txt ${FGT_EV}
                        mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_shock_timings.txt ${SHK_EV}

                            #replacing subject-specific task timing and motion parameters as EVs to the fsf file IF OUTLIERS WERE DETECTED
                            if [ -f "$CON_MTX" ]; then
                                echo "Found Motion Confounds Matrix for MCA${SUBJ}_Ses${SES}_Mem${TASK}" 

                                for i in 'MCA_Mem_firstleveldesign_template_mpCON_oacV.fsf'; do # finds marker/flags in the template fsf 
                                sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                                    -e 's@INPUT@'${INPUT}'@g' \
                                    -e 's@NVOLS@'${NVOLS}'@g' \
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
                                        -e 's@ANAT@'${ANAT}'@g' \
                                        -e 's@REGSTD@'${REGSTD}'@g' \
                                        -e 's@RK_EV@'${RK_EV}'@g' \
                                        -e 's@FGT_EV@'${FGT_EV}'@g' \
                                        -e 's@SHK_EV@'${SHK_EV}'@g' <$j> ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstleveldesign.fsf

                                    #runs the FSL analysis using the updated fsf file      
                                        if [ -f "$RK_EV" ]; then #check interchangeably w FGT_EV and SHK_EV && [-f "$FGT_EV"] && [-f "$SHK_EV"]
                                        echo "Running First Level Stats for MCA${SUBJ}_Ses${SES}_Mem${TASK} with NO MOTION CONFOUNDS"               
                                        feat ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstleveldesign.fsf
                                        else                  
                                        echo "Timing file not avaliable for MCA${SUBJ}_Ses${SES}_Mem${TASK}"
                                        fi

                                done
                            fi
                    fi  
                else
                echo "No Memory Data" 
                fi
            
        done    
    done
# done        
echo All Runs Done
