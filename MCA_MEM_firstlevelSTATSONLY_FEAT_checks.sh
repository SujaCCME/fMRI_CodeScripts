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

SUBJ=10 # (Next: 11, 12 for individual runs)
SES=1 # for trial runs or individual runs
# TASK=2 # for trial runs or individual runs

# for SUBJ in {13..116}
# do
#     for SES in 1 2 
#     do
        for TASK in 1 2
        do
                # if [ -f "${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_corrected.nii.gz" ]; then
                PROCESSED=false        
                    for DIR in "${DATADIR}/FSL_Mem/First_Level_Subj_Analyses/${SUBJ}-${SES}-m${TASK}_Pre_"*_*.feat; do
                        if [ -d "${DIR}/${SUBJ}-${SES}-m${TASK}_Stats.feat" ]; then
                            open ${DIR}/${SUBJ}-${SES}-m${TASK}_Stats.feat/report.html
                            echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} already processed with full confounds set. Skipping to next FEAT..."
                            PROCESSED=true
                            break
                        fi
                        
                        if [ "${PROCESSED}" = false ]; then
                            echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} NOT processed with full confounds..."

                            INPUT=${DIR}/filtered_func_data_reg.nii.gz
                            printf "Registered Functionl Data Input: ${INPUT}\n"

                            NVOLS=$(fslnvols ${INPUT}) # updates fsf file with number of vols/timepoints for the fmri run in this session-task from FSLNVOLS fslutil command
                            NVXLS=$(fslstats ${INPUT} -V | awk '{print $1}') # updates fsf file with number of voxels for the fmri run in this session-task from FSLSTATS command; the first element of the array stored from $(fslstats ${INPUT})
                            REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
                            CON_MTX=${DIR}/filtered_func_data_reg_mp6_fdrms1pt5_CmCrn5.txt #confounds matrix from motion parameters, motion outliers fdrms>1.5mm, n5 CompCor
                            RK_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_RorK_words_FSL.txt # "Remember/Know" words timing file
                            FGT_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_SF_words.txt # "Forgot" words timing file
                            SHK_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_shock_timings.txt # "Shock" words timing file
                            OUTPUTDIR=${DIR}/${SUBJ}-${SES}-m${TASK}_Stats.feat
                            
                            echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} being processed..."

                            #checks if the timing files are available for the subject, session, and task
                           
                            if [ ! -f "$RK_EV" ] && [ ! -f "$FGT_EV" ] && [ ! -f "$SHK_EV" ]; then 
                                # moving txt files to the FSL_Mem directory for EV input to the fsf file
                                mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_RorK_words_FSL.txt ${RK_EV}
                                mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_SF_words.txt ${FGT_EV}
                                mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_shock_timings.txt ${SHK_EV}
                            fi
                            
                            if [ -f "$RK_EV" ] && [ -f "$FGT_EV" ] && [ -f "$SHK_EV" ]; then
                                    #replacing subject-specific task timing and motion parameters as EVs to the fsf file IF OUTLIERS WERE DETECTED
                                    if [ -f "$CON_MTX" ]; then
                                        echo "Found Confounds Matrix : MCA${SUBJ}_Ses${SES}_Mem${TASK}" 

                                        for i in 'MCA_Mem_StatsOnly_design_template_mpCON_oacV.fsf'; do # finds marker/flags in the template fsf 
                                            sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                                                -e 's@INPUT@'${INPUT}'@g' \
                                                -e 's@NVOLS@'${NVOLS}'@g' \
                                                -e 's@NVXLS@'${NVXLS}'@g' \
                                                -e 's@CON_MTX@'${CON_MTX}'@g' \
                                                -e 's@REGSTD@'${REGSTD}'@g' \
                                                -e 's@SHK_EV@'${SHK_EV}'@g' \
                                                -e 's@RK_EV@'${RK_EV}'@g' \
                                                -e 's@FGT_EV@'${FGT_EV}'@g' <$i> ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstlevelSTATSONLYdesign.fsf
                                                # -e 's@SHK_EV@'${SHK_EV}'@g' <$i> ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstlevelSTATSONLYdesign.fsf

                                                # runs the FSL analysis using the newly created fsf file                      
                                            
                                                echo "Running First Level Stats for MCA${SUBJ}_Ses${SES}_Mem${TASK} with full confound set..."               
                                                # feat ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstlevelSTATSONLYdesign.fsf
                                                feat ${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_${SES}_${TASK}_Mem_firstlevelSTATSONLYdesign.fsf

                                                echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} processed with full confound set."
                                                
                                                # copy reg_standard folders to the STATSONLY output directory
                                                cp -r ${OUTPUTDIR}/reg_standard ${OUTPUTDIR}/reg_standard
                                                echo "Copied reg_standard folder to ${OUTPUTDIR}... Redundant Copy to avoid errors in the second/third level analysis"
                                         done                                           

                                    else
                                        echo "Confounds set missing - ${DIR}"   
                                        echo "${DIR} full confound set NOT processed . Skipping to next run..."
                                    fi
                            else
                                    echo "Timing file not avaliable: MCA${SUBJ}_Ses${SES}_Mem${TASK}"
                            fi
                        else
                            echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} already processed. Skipping to next run..."
                        fi
                    done 

                # else 
                #     echo Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} NOT found. Skipping to next run...
                # fi

        done
#     done
# done