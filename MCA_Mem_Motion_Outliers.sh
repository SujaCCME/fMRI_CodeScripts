#!/bin/bash
## Run from MCA study "Data" folder, after MRIcroGL dicom to .nii.gz conversion, Fieldmap correction and Brain Extraction; req's file = datain.txt (contains param's)

#fsl_motion_outliers : runs motion calculations; Does Motion Correction (or not, usually with --nomoco for using MCFLIRT before/after via GUI; if using framewise displacement as the metric, have motion correction ON), finds Outliers, and creates Confound Matrix for GLM in First Level Preprocessing

#Reference: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLMotionOutliers

#############################################################################
# for individual runs, use the following:

# Subj=76
# Ses=2
# Task=2

for Subj in {70..71}
do
    for Ses in {1..2}
    do
          for Task in {1..2}
          do


#################### Should not need to edit below this line ################

                        echo "\n Running Subject ${Subj} Session ${Ses}"

                        date
                        echo Starting Motion Calcs...
                        DATADIR=$PWD

                        # DATALABEL=MCA${Subj}_Ses${Ses}_Mem${Task}
                        
                        # check for any data with scrubbed volumes 
                        if [ -f "${DATADIR}/MCA${Subj}_Ses${Ses}/Mem${Task}_func/${DATALABEL}_corrected_scrubbed.nii.gz" ]; then
                        INPUT=${DATADIR}/MCA${Subj}_Ses${Ses}/Mem${Task}_func/${DATALABEL}_corrected_scrubbed.nii.gz
                        else
                        INPUT=${DATADIR}/MCA${Subj}_Ses${Ses}/Mem${Task}_func/${DATALABEL}_corrected.nii.gz
                        fi

                    ##################### MEMORY DATA ####################

                        echo "Memory Data MCA${Subj}_Ses${Ses}_Mem${Task} being processed..."
                            fsl_motion_outliers -i ${INPUT} -o ./MCA${Subj}_Ses${Ses}/Mem${Task}_func/${DATALABEL}_mp-confoundsMtx.txt -s ./MCA${Subj}_Ses${Ses}/Mem${Task}_func/${DATALABEL}_fdrms.txt -p ./MCA${Subj}_Ses${Ses}/Mem${Task}_func/${DATALABEL}_fdrms_plot.png --fdrms --thresh=1.5 --dummy=0 -v
                            wait
                            echo "Subj MCA${Subj} MEM Done"
                        
                   
          done
    done
done
echo All Done! 

date