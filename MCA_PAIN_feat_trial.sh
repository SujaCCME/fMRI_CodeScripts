#!/bin/bash
#ref: https://wiki.biac.duke.edu/biac:fsl:guide

######### run this script from MCA_FMRI/Public/Data directory; edits template  MCA_Pain_firstleveldesign_template_oacV.fsf from Data folder to do subject specific GLM design based on motion confounds data


#loads the fsl program
#export FSLDIR=/usr/local/packages/fsl
#.${FSLDIR}/etc/fslconf/fsl.sh
 

#DATADIR=/Volumes/cerebro/Studies/MCA_FMRI/Public/Data
DATADIR=$PWD
label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with the current timestamp when the script is executed
#########
 
#makes the compounded GLM design first-level FEAT file
# SUBJ=115 # for trial runs or individual runs
# SES=1 # for trial runs or individual runs
for SUBJ in {7..116} 
do
    for SES in 1 2 
    do               
        INPUT=${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_Ses${SES}_Pain_corrected
        if [ -f "${INPUT}".nii.gz ]; then
                echo "Found Pain Data MCA${SUBJ}_Ses${SES}"
                echo $(fslnvols ${INPUT}) volumes for MCA${SUBJ}_Ses${SES}
            if [ -d "${DATADIR}/FSL_Pain/First_Level_Subj_Analyses/${SUBJ}-${SES}_Pre_"*.feat ]; then  #checks if the output directory already exists
                echo "Pain Data MCA${SUBJ}_Ses${SES} already processed. Skipping to next run..."  
                continue;
            else
                echo DOING ERROR PRONE FEAT ANALYSIS for MCA${SUBJ}_Ses${SES}
            fi
                
        else echo NO PAIN DATA for MCA${SUBJ}_Ses${SES} 
        fi
    done
done