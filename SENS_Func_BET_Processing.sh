#!/bin/bash
########################################################################################################################################################################################################################################################### 

# NOTE: Runs BET extraction on the functional images, and tRequires FSL to be installed on the system; see https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation for installation instructions

########################################################################################################################################################################################################################################################### 

DATADIR=/Volumes/cerebro/Studies/VOGT/SENS/Public/Data
Subj="20" #set subj number here 
########################################################################################################################################################################################################################################################### 

# for Subj in $(seq -f "%02g" 6 14) # do SENS 7 run 3 
# do
#     # Run="02" #set session number here
    for Run in $(seq -f "%02g" 1 2)
    do
        
        if [ -d "${DATADIR}/SENS_BIDS/sub-ID${Subj}" ]; then

                echo Running SENS-${Subj} Run-${Run}...
                date

                # make a directory for each subject in derivatives folder
                DERIV_DIR="${DATADIR}/SENS_BIDS/derivatives/sub-ID${Subj}"
                
                # make a directory for each subject in derivatives folder if not already present
                if [ ! -d "${DATADIR}/SENS_BIDS/derivatives/sub-ID${Subj}/func" ]; then
                    
                    mkdir -p ${DERIV_DIR}/func
                    
                fi
        
                echo "Defacing Func data for Subject SENS-${Subj}..."
                

                # BET extraction
                # MEM
                echo Running brain extraction with BET...
                bet ${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-${Run}_bold.nii.gz ${DERIV_DIR}/func/sub-ID${Subj}_task-mem_run-${Run}_bold_brain.nii.gz -F -f 0.3 -g 0.2
                wait
                echo Mem BET sub-ID${Subj} done!

                # REST
                bet ${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-rest_run-${Run}_bold.nii.gz ${DERIV_DIR}/func/sub-ID${Subj}_task-rest_run-${Run}_bold_brain.nii.gz -F -f 0.3 -g 0.2
                echo Rest BET sub-ID${Subj} done!
                           
        else
            echo "SENS-${Subj} Data Not Available!"
        fi
        wait
    done
# ###########################################################################################################################################################################################################################################################
# done
echo "All Subjects Func Data Processing Done!"

