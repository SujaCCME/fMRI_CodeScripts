#!/bin/bash
#ref: https://wiki.biac.duke.edu/biac:fsl:guide

######### run this script from MCA_FMRI/Public/Data directory; COMPUTES NUMBER OF VOLUMES IN EACH PAIN SCAN


#loads the fsl program
#export FSLDIR=/usr/local/packages/fsl
#.${FSLDIR}/etc/fslconf/fsl.sh
 

#DATADIR=/Volumes/cerebro/Studies/MCA_FMRI/Public/Data
DATADIR=$PWD
label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with the current timestamp when the script is executed
#########

# SUBJ=116 # for trial runs or individual runs
# SES=1 # for trial runs or individual runs
for SUBJ in {7..116} 
do
    for SES in 1 2 
    do               
        INPUT=${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_Ses${SES}_Pain_corrected.nii.gz
        if [ -f "${INPUT}" ]; then
                echo "Found Pain Data MCA${SUBJ}_Ses${SES}"
                echo $(fslnvols ${INPUT})
        else
                echo "No Pain Data MCA${SUBJ}_Ses${SES}"
        fi   
    done
done