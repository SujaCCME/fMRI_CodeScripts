#!/bin/bash
# Run from /Volumes/cerebro/../NeuCLA/Public/Data/SENS_BIDS/code directory

# NOTE 1: Converts the originally acquired DICOM data into fMRI BIDS format for further processing
# NOTE 2: Checks if the BIDS files (Pain and Resting state) have the intended original number of volumes converted from raw DICOM files
# NOTE 3: Requires dcm2bids to be installed on the system, check version(s), environment and path settings for the shell to avoid errors during call; see dcm2bids_config.json for the configuration file generated from 3T acquisition parameters
# NOTE 4: Requires FSL to be installed on the system; see https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation for installation instructions
# NOTE 5: Most recent log files of the dcm2bids conversion can located using the datestamp and timestamp suffixes. All files are stored in the /SENS_BIDS/tmp_dcm2bids/log directory  
# NOTE 6: Events files for each scan/run are created from the template events info for SENS data, any scan-specific edits are to be made manually in the subject's BIDS sub-folders

# As a QC, outputs total number of volumes in task and RS scans for each subject

# For details on dcm2bids configuration, see 1. https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html, 2. https://unfmontreal.github.io/Dcm2Bids/3.1.1/tutorial/first-steps/

# Path to the Study data
DATADIR="/Volumes/cerebro/Studies/VOGT/SENS/Public/Data"
INDIR="/Users/vogtlab/downloads/202020"

Subj="202020"

# for Subj in $(seq -f "%02g" 7 10) #looping through all the subjects included in the analysis
# do
   

    # Path to the raw DICOM data
    # INDIR="${DATADIR}/SENS-${Subj}/Raw_data" 
    # INDIR="${DATADIR}/files" # trial

    if [ -d "$INDIR" ]; then

        # echo "Converting Subj ${Subj} into BIDS..."
        
        # DCM2NIIX conversion Only, if needed for editing dcm2bids_config.json; all non-BIDS nii/json intermediate files are stored in SENS_BIDS/tmp_dcm2bids/ directory
        # /Volumes/MRIcroGL/MRIcroGL.app/Contents/Resources/dcm2niix -f "%p" -p y -z y -o ${DATADIR}/SENS-05/Original_data ${INDIR}

        # DCM2NIIX conversion and then BIDS conversion
        dcm2bids -d ${INDIR} -p ID${Subj} -c ${DATADIR}/SENS_BIDS/code/dcm2bids_config.json -o ${DATADIR}/SENS_BIDS --auto_extract_entities --bids_validate  #--force_dcm2bids --clobber #--bids_validate 
        
        echo "SENS${Subj} fMRI nii.gz to BIDS Conversion Complete"


        # Checking if the data has complete set of files ; Pain NVOLS=225 and RS NVOLS=600 for SENS study
            # Pain data
            # IN_P1=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-01_bold.nii.gz
            # NVOLS_P1=$(fslnvols ${IN_P1})
            # IN_P2=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-mem_run-02_bold.nii.gz
            # NVOLS_P2=$(fslnvols ${IN_P2})

            # Rest 
            # IN_R1=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-rest_run-01_bold.nii.gz
            # NVOLS_R1=$(fslnvols ${IN_R1}) 
            # IN_R2=${DATADIR}/SENS_BIDS/sub-ID${Subj}/func/sub-ID${Subj}_task-rest_run-02_bold.nii.gz
            # NVOLS_R2=$(fslnvols ${IN_R2})  

            # wait

            # # SENS data QC: Task scan volumes=460, Resting state scan volumes=460
            # echo "Total volumes found: Pain1 - ${NVOLS_P1}  Pain2 - ${NVOLS_P2}"
            # # echo "Total volumes found: Rest1 - ${NVOLS_R1}  Rest2 - ${NVOLS_R2}"

            # # if the volumes are not as expected, print a statement
            # if [ $NVOLS_P1 -ne 460 ] || [ $NVOLS_P2 -ne 460 ] || [ $NVOLS_R1 -ne 460 ] || [ $NVOLS_R2 -ne 460 ]; then
            #     echo "NOTE: fMRI scans missing intended volumes."
            # fi
            
            echo "SENS ${Subj} Events Files are being created..."
            
             # # create event files for each run
            # shutil.copyfile(f'{DATADIR}/Bash_Scripts_Templates/SENS_template_events.tsv', f'{DATADIR}/SENS_BIDS/sub-${Subj}/func/sub-${Subj}_task-mem_run-01_events.tsv')
            # shutil.copyfile(f'{DATADIR}/Bash_Scripts_Templates/SENS_template_events.tsv', f'{DATADIR}/SENS_BIDS/sub-${Subj}/func/sub-${Subj}_task-mem_run-02_events.tsv')

            # # create event JSON files for each run
            # shutil.copyfile(f'{DATADIR}/Bash_Scripts_Templates/SENS_template_events.json', f'{DATADIR}/SENS_BIDS/sub-${Subj}/func/sub-${Subj}_task-mem_run-01_events.json')
            # shutil.copyfile(f'{DATADIR}/Bash_Scripts_Templates/SENS_template_events.json', f'{DATADIR}/SENS_BIDS/sub-${Subj}/func/sub-${Subj}_task-mem_run-02_events.json')

            echo "SENS${Subj} Events Files Created"

    else
        echo "SENS${Subj} Data Not Available"
    fi
    wait
# done