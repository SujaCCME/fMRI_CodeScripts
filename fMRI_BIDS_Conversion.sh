#!/bin/bash
# NOTE 1: Converts the originally acquired DICOM data into fMRI BIDS format for further processing
# NOTE 2: Checks if the BIDS files (Pain and Resting state) have the intended original number of volumes converted from raw DICOM files
# NOTE 3: Requires dcm2bids to be installed on the system; see dcm2bids_config.json for the configuration file generated from acquisition parameters
# NOTE 4: Requires FSL to be installed on the system; see https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation for installation instructions

######### run this script from the main server directory #########

# DATADIR=/path/to/the/server/fMRI/data/directory
DATADIR=$PWD
N = 53 #last subject's ID in the dataset

for Subj in $(seq -f "%02g" 1 53)  # looping through all subjects with zero-padding to keep uniform characterization in the subject-IDs in the BIDS directories
do

    # Subj=53 #in case of a single subject run

    INDIR=${DATADIR}/sourcedata/PIB${Subj}/Raw_data
            
                if [ -d "${INDIR}" ]; then
                    
                    echo "Converting Subj ${Subj} into BIDS format..."
                    dcm2bids -d ${INDIR} -p ID${Subj} -c ${DATADIR}/code/dcm2bids_config.json -o ${DATADIR} --auto_extract_entities --force_dcm2niix --clobber #--bids_validate
                    echo "PIB${Subj} converted to BIDS. Data added to the BIDS layout"
                    wait
                    
                    ########## Pain data #########
                    IN_P=${DATADIR}/sub-ID${Subj}/func/sub-ID${Subj}_task-pain_bold.nii.gz
                    # check the total number of volumes in the pain task data
                    NVOLS_P=$(fslnvols ${IN_P}) 

                    ########## Rest data #########
                    IN_R=${DATADIR}/sub-ID${Subj}/func/sub-ID${Subj}_task-rest_bold.nii.gz
                    # check the total number of volumes in the resting state data
                    NVOLS_R=$(fslnvols ${IN_R})  
                                
                    echo "Total volumes found: Pain - ${NVOLS_P} and Rest - ${NVOLS_R} Done"

                else
                    echo "PIB${Subj} Data Not Available"
                fi
                wait
done
