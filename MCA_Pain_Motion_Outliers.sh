#!/bin/bash
## Run from MCA study "Data" folder, after MRIcroGL dicom to .nii.gz conversion, Fieldmap correction and Brain Extraction; req's file = datain.txt (contains param's)

# NOTE: Move any and all prior data to a backup folder before running this script, as it will overwrite any existing files with the same name to avoid reddundancy
# NOTE: fdrms.txt and mp-confoundsMtx.txt files are saved to mp_beforescrubbing folder before running scrubbed.nii.gz data

#fsl_motion_outliers : runs motion calculations; Does Motion Correction (or not, usually with --nomoco for using MCFLIRT before/after via GUI; if using framewise displacement as the metric, have motion correction ON), finds Outliers, and creates Confound Matrix for GLM in First Level Preprocessing

#Reference: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLMotionOutliers

#############################################################################

date
echo Starting Motion Calcs...
DATADIR=$PWD

# for individual runs, use the following:
# Subj=76
# Ses=2
# Task=2

#############################################################################
for Subj in {7..116}
do
    for Ses in {1..2}
    do
       
                #####################PAIN DATA ####################
                DATALABEL=MCA${Subj}_Ses${Ses}_Pain

                if [ -f "${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_corrected.nii.gz" ] || [ -f "${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_corrected_scrubbed.nii.gz" ]; then
                echo ${DATALABEL} - scan found

                    if [ -f ${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_fdrms.txt ]; then
                        echo Pain Data ${DATALABEL} Motion Outliers Detection Completed
                    else    
                        
                        echo "Pain Data ${DATALABEL} being processed..."

                        # check for any data with scrubbed volumes 
                        if [ -f "${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_corrected_scrubbed.nii.gz" ]; then
                        INPUT=${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_corrected_scrubbed.nii.gz
                        else
                        INPUT=${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_corrected.nii.gz
                        fi   
                        echo "Subj ${DATALABEL} Pain Done"

                        fsl_motion_outliers -i ${INPUT} -o ${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_mp-confoundsMtx.txt -s ${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_fdrms.txt -p ${DATADIR}/MCA${Subj}_Ses${Ses}/Pain_func/${DATALABEL}_fdrms_plot.png --fdrms --thresh=1.5 --dummy=0 -v
                        wait

                    fi
                else echo ${DATALABEL} - scan not found
                fi

                
    done
done

echo All Done! 

date