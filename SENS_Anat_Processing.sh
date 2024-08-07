#!/bin/bash

# NOTE 1: Defaces the BIDS compliant T1w and T2w images using pydeface; uses MNI template for defacing
# NOTE 2: Runs BET extraction on the defaced images, and then runs FAST segmentation on the extracted brain images
# NOTE 4: Requires pydeface to be installed on the system, check version(s), environment and path settings for the shell to avoid errors during call
# NOTE 5: Requires FSL to be installed on the system; see https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation for installation instructions

# NOTE 6: subjects SENS 5-17 have runs 1 and 2 for T1w and T2w scans- later informed as run 2 are intensity corrected, 

DATADIR=/Volumes/cerebro/Studies/VOGT/SENS/Public/Data/SENS_BIDS
Subj="14" #set subj number here 
# for Subj in $(seq -f "%02g" 6 8) #set subj number here for loops
# do
    # Run="02" #set session number here
    for Run in $(seq -f "%02g" 1 2)
    do
        
        if [ -d "${DATADIR}/sub-ID${Subj}" ]; then
############################################################################################################################################################################################################################################################ 
                echo Running SENS-${Subj} Run${Run}...
                date

                # make a directory for each subject in derivatives folder
                DERIV_DIR="${DATADIR}/derivatives/sub-ID${Subj}"
                mkdir -p ${DERIV_DIR}/anat

        
                echo "Defacing Anat data for Subject SENS-${Subj}..."
                

                # Defacing the T1w and T2w images using pydeface
                #T1w
                pydeface --outfile  ${DATADIR}/sub-ID${Subj}/anat/sub-ID${Subj}_run-${Run}_T1w.nii.gz --force --cost mutualinfo --verbose ${DATADIR}/sub-ID${Subj}/anat/sub-ID${Subj}_run-${Run}_T1w.nii.gz # --facemask path   
                wait
                
                #T2w
                # pydeface --outfile  ${DATADIR}/sub-ID${Subj}/anat/sub-ID${Subj}_run-${Run}_T2w.nii.gz --force --cost mutualinfo --verbose ${DATADIR}/sub-ID${Subj}/anat/sub-ID${Subj}_run-${Run}_T2w.nii.gz # --facemask path
                # wait

                echo "SENS-${Subj}-Run${Run} Anat Data Defacing Done!"

                        # BET extraction
                        #T1w
                        echo Running brain extraction with BET...
                        bet ${DATADIR}/sub-ID${Subj}/anat/sub-ID${Subj}_run-${Run}_T1w.nii.gz ${DERIV_DIR}/anat/sub-ID${Subj}_run-${Run}_T1w_brain.nii.gz -R -f 0.3 -g 0.2 
                        echo SENS_${Subj}_T1w ${Run} BET done!
                        wait

                        #T2w
                        # bet ${DATADIR}/sub-ID${Subj}/anat/sub-ID${Subj}_run-${Run}_T2w.nii.gz ${DERIV_DIR}/anat/sub-ID${Subj}_run-${Run}_T2w_brain.nii.gz -R -f 0.3 -g 0.2 
                        # echo SENS_${Subj}_T2w ${Run} BET done!
                        # wait

                        #FAST brain segmentation
                        echo Running T1w FAST segmentation ...
                        FAST -g ${DERIV_DIR}/anat/sub-ID${Subj}_run-${Run}_T1w_brain.nii.gz
                        wait
                        echo SENS_${Subj}_run-${Run} FAST segmentation done!
        else
            echo "SENS-${Subj} Data Not Available!"
        fi
        wait
    done
# done
echo "All Subjects Anat Data Processing Done!"