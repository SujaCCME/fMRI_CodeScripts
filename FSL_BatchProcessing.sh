#!/bin/bash
#NOTE: Runs a batch of fMRI functional data on FSL FEAT pipeline; based on confounds data available, edits a pre-made template viz. firstleveldesign.fsf

######### run this preprocessing script from the main server directory #########

# DATADIR=/path/to/the/server/fMRI/data/directory
DATADIR=$PWD
label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with timestamp

# N = 36 #last subject's ID in the dataset

# SUBJ=36 #in case of a single subject run
# RUN=2 #in case of a specific run

for SUBJ in {1..36} #looping through all available subjects in the dataset
do
    for RUN in 1 2 #each subject performs two runs of the task
    do    
        for INPUTDIR in ${DATADIR}/NLA${SUBJ}/Pain_func${RUN}; do  
            if [ -f "${DATADIR}/NLA${SUBJ}/Pain_func${RUN}/NLA${SUBJ}_Pain${RUN}_corrected.nii.gz" ]; then

                INPUT=${DATADIR}/NLA${SUBJ}/Pain_func${RUN}/NLA${SUBJ}_Pain${RUN}_corrected.nii.gz # subject's functional image
                NVOLS=$(fslnvols ${INPUT}) # updates fsf file with number of vols/timepoints for the fmri run in this session-task from FSLNVOLS fslutil command
                ANAT=${DATADIR}/NLA${SUBJ}/Anat/NLA${SUBJ}_T1_anat_brain.nii.gz # subject's anatomical image
                REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz # standard anatomical image for registration
                
                # fMRI design paradigm's Task Timing file; some subjects have custom timing files viz NLA27_pain_timing_Pain2.txt and NLA_pain_timing_NLA12 for subjects 27 and 12 respectively
                TMG=${DATADIR}/NLA_pain_timing.txt 

                # Confounds matrix from motion outliers detected from NLA_Motion_Outlier_Detection.sh script    
                # CON_MTX=${DATADIR}/NLA${SUBJ}/Pain_func${RUN}/NLA${SUBJ}_Pain${RUN}_mp-confoundsMtx.txt # excluded for NLA as there are no subjects with motion outliers greater than the set fdrms threshold

                # Confounds matrix from high variance confounds detected from nilearn's high_variance_confounds from the preparatory .ipynb notebook
                CON_MTX=${DATADIR}/HVC/NLA${SUBJ}_Pain${RUN}_hvc.txt

                OUTPUTDIR=${DATADIR}/NLA${SUBJ}/Pain_func${RUN}/NLA${SUBJ}_Pain${RUN}_Pre_${label}

                #replacing subject-specific task timing and motion parameters as explanatory variables (EVs) to the fsf file IF OUTLIERS WERE DETECTED
                if [ -f "$CON_MTX" ]; then
                    # echo "Found Motion Confounds Matrix for NLA${SUBJ}_Pain${RUN}" 
                    echo "Found High Variance Confounds Matrix for NLA${SUBJ}_Pain${RUN}"

                    for i in 'NLA_firstleveldesign_template_mpCON.fsf'; do # finds marker/flags in the template fsf 
                        sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                            -e 's@INPUT@'${INPUT}'@g' \
                            -e 's@NVOLS@'${NVOLS}'@g' \
                            -e 's@TMG@'${TMG}'@g' \
                            -e 's@CON_MTX@'${CON_MTX}'@g' \
                            -e 's@ANAT@'${ANAT}'@g' \ 
                            -e 's@REGSTD@'${REGSTD}'@g' \ 
                            <$i> ${DATADIR}/NLA${SUBJ}/Pain_func${RUN}/NLA${SUBJ}_Pain${RUN}_firstleveldesign.fsf

                        #runs the FSL analysis using the newly created fsf file   
                        echo "Running First Level Stats for NLA${SUBJ}_Pain${RUN} ..."               
                        feat ${DATADIR}/NLA${SUBJ}/Pain_func${RUN}/NLA${SUBJ}_Pain${RUN}_firstleveldesign.fsf
                    done

                else
                    # echo "No Motion Outliers in NLA${SUBJ}_Pain${RUN}"   # if needed, change motion outlier threshold in FirstLevelDataPrep.sh script for desired metric values
                    echo "No High Variance Confounds in NLA${SUBJ}_Pain${RUN}" 
                    
                    for j in 'NLA_firstleveldesign_template_NOmpCON.fsf'; do # finds marker/flags in the template fsf 
                        sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                            -e 's@INPUT@'${INPUT}'@g' \
                            -e 's@NVOLS@'${NVOLS}'@g' \
                            -e 's@ANAT@'${ANAT}'@g' \
                            -e 's@REGSTD@'${REGSTD}'@g' \
                            -e 's@TMG@'${TMG}'@g' \
                            <$j> ${DATADIR}/NLA${SUBJ}/Pain_func${RUN}/NLA${SUBJ}_Pain${RUN}_firstleveldesign.fsf

                        #runs the FSL analysis using the newly created fsf file   
                        echo "Running First Level Stats for NLA${SUBJ}_Pain${RUN} ..."               
                        feat ${DATADIR}/NLA${SUBJ}/Pain_func${RUN}/NLA${SUBJ}_Pain${RUN}_firstleveldesign.fsf
                    done
                fi  
            else
                echo "No Data Available for NLA${SUBJ}" 
            fi
        done
    done
done
 
echo All Runs Done