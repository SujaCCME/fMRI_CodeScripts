# Run from cerebro/../NeuCLA/Public/Data/NLA_BIDS directory


#!/bin/bash

DATADIR="/Volumes/cerebro/Studies/VOGT/NeuCLA/Public/Data"

for Subj in $(seq -f "%02g" 2 35) #looping through all the subjects included in the analysis
# Subj=9

do

INDIR="${DATADIR}/NLA${Subj}/Raw" 

if [ -d "$INDIR" ]; then
    echo "Converting Subj ${Subj} into BIDS..."
    
    dcm2bids -d ${INDIR} -p ID0${Subj} -c ${DATADIR}/NLA_BIDS/code/dcm2bids_config.json -o ${DATADIR}/NLA_BIDS --auto_extract_entities #--force_dcm2bids --clobber #--bids_validate 
    
    echo "NLA${Subj} Done"

    # Checking if the data has complete set of files ; Pain NVOLS=225 and RS NVOLS=600 for NLA study
        # Pain data
        IN_P1=${DATADIR}/NLA_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-pain_run-01_bold.nii.gz
        NVOLS_P1=$(fslnvols ${IN_P1})
        IN_P2=${DATADIR}/NLA_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-pain_run-02_bold.nii.gz
        NVOLS_P2=$(fslnvols ${IN_P2})
        # Rest 
        IN_R1=${DATADIR}/NLA_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-rest_run-01_bold.nii.gz
        NVOLS_R1=$(fslnvols ${IN_R1}) 
        IN_R2=${DATADIR}/NLA_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-rest_run-02_bold.nii.gz
        NVOLS_R2=$(fslnvols ${IN_R2})  
                        
        echo "Total volumes found: Pain1 - ${NVOLS_P1} and Pain2 - ${NVOLS_P2}"
        echo "Total volumes found: Rest1 - ${NVOLS_R1} and Rest2 - ${NVOLS_R2}"
else
    echo "NLA${Subj} Data Not Available"
fi
wait
done