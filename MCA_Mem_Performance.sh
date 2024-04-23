#!/bin/bash

######### run from MCA_FMRI/Public/Data directory; needs MCA timing files from R/K, FGT, and Shock data 
# outputs four files for each of the 3 event's count and Data_NA.txt for missing timing files. Run:   bash ./MCA_Mem_Performance.sh >> ./MCA_Mem_Performance/Data_NA.txt

#loads the fsl program
#export FSLDIR=/usr/local/packages/fsl
#.${FSLDIR}/etc/fslconf/fsl.sh
 

#DATADIR=/Volumes/cerebro/Studies/MCA_FMRI/Public/Data
DATADIR=$PWD
#label=$(date +"%m%d%Y_%H%M%S")
RK_OUT=${DATADIR}/MCA_Mem_Performance/MCA_RorK_count.txt
FGT_OUT=${DATADIR}/MCA_Mem_Performance/MCA_FGT_count.txt
SHK_OUT=${DATADIR}/MCA_Mem_Performance/MCA_SHK_count.txt
DataNA=${DATADIR}/MCA_Mem_Performance/Data_NA.txt
######################################################
SUBJ=90     #for trial runs
# SES=2 
# for SUBJ in {91..116} 
# do
        for SES in 1 2 
        do
            for TASK in 1 2 
            do
                for INPUTDIR in ${DATADIR}/FSL_Mem/First_Level_Subj_Analyses/${SUBJ}-${SES}-m${TASK}_Pre_*.feat; do
                
                RK_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_RorK_words_FSL.txt
                FGT_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_SF_words.txt
                SHK_EV=${DATADIR}/FSL_Mem/MCA${SUBJ}_Ses${SES}_Mem${TASK}_shock_timings.txt

                # moving txt files to the FSL_Mem directory for EV input to the fsf file
                mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_RorK_words_FSL.txt ${RK_EV}
                mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_SF_words.txt ${FGT_EV}
                mv ${DATADIR}/Timing_Calculations/MCA${SUBJ}_Ses${SES}_Mem${TASK}_shock_timings.txt ${SHK_EV}

                    #find REM+KNOW words for IF TIMING FILE IS AVAILABLE
                    if [ -f "$RK_EV" ]; then
                        # echo "REM/KNW MCA${SUBJ} Ses${SES} Mem${TASK}:" >> ${RK_OUT}
                        # cat ${RK_EV} | wc -l >> ${RK_OUT}
                        wcREM_KNW=$(sed -n '$=' ${RK_EV})                    
                        echo "REM/KNW MCA${SUBJ} Ses${SES} Mem${TASK} ${wcREM_KNW}" >> ${RK_OUT}
                    else
                        echo "No REM/KNW Data Available for MCA${SUBJ}_Ses${SES}_Mem${TASK}" >> ${DataNA} 
                    fi

                    #find Forgotten words IF TIMING FILE IS AVAILABLE
                    if [ -f "$FGT_EV" ]; then                       
                        # echo "FGT MCA${SUBJ} Ses${SES} Mem${TASK}:" >> ${FGT_OUT}
                        # cat ${FGT_EV} | wc -l >> ${FGT_OUT}
                        wcFGT=$(sed -n '$=' ${FGT_EV})                    
                        echo "FGT MCA${SUBJ} Ses${SES} Mem${TASK} ${wcFGT}" >> ${FGT_OUT}
                    else
                        echo "No FGT Data Available for MCA${SUBJ}_Ses${SES}_Mem${TASK}" >> ${DataNA}  
                    fi
                    
                    #find Shocked words IF TIMING FILE IS AVAILABLE
                    if [ -f "$SHK_EV" ]; then 
                        # echo "SHK MCA${SUBJ} Ses${SES} Mem${TASK}:" >> ${SHK_OUT}
                        # cat ${SHK_EV} | wc -l >> ${SHK_OUT}
                        wcSHK=$(sed -n '$=' ${SHK_EV})                    
                        echo "SHK MCA${SUBJ} Ses${SES} Mem${TASK} ${wcSHK}" >> ${SHK_OUT}
                    else
                        echo "No SHK Data Available for MCA${SUBJ}_Ses${SES}_Mem${TASK}" >> ${DataNA}
                    fi

                done
            done
        done
# done
 
 echo All Runs Done
