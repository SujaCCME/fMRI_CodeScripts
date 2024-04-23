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
SUBJ=23 # for trial runs or individual runs
SES=1 # for trial runs or individual runs


# for SUBJ in {7..94} 
# do
#     for SES in 1 2 
#     do               
        INPUT=${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_Ses${SES}_Pain_corrected
        if [ -f "${INPUT}".nii.gz ]; then
                echo "Found Pain Data MCA${SUBJ}_Ses${SES}"
                echo $(fslnvols ${INPUT})
            if [ -d "${DATADIR}/FSL_Pain/First_Level_Subj_Analyses/${SUBJ}-${SES}_Pre_"*.feat ]; then  #checks if the output directory already exists
                echo "Pain Data MCA${SUBJ}_Ses${SES} already processed. Skipping to next run..."  
                continue;
            else
                NVOLS=$(fslnvols ${INPUT}) # updates fsf file with number of vols/timepoints for the fmri run in this session-task from FSLNVOLS fslutil command
                ANAT=${DATADIR}/MCA${SUBJ}_Ses${SES}/T1/MCA${SUBJ}_T1_anat_brain
                REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain
                CON_MTX=${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_Ses${SES}_Pain_mp-confoundsMtx.txt #confounds matrix from motion outliers
                OUTPUTDIR=${DATADIR}/FSL_Pain/First_Level_Subj_Analyses/${SUBJ}-${SES}_Pre_${label}

                # Updating design matrix with EVs to the fsf file IF OUTLIERS WERE DETECTED
                if [ -f "$CON_MTX" ]; then
                    echo "Found Motion Confounds Matrix. Added to GLM to preprocess Pain Scan in MCA${SUBJ}_Ses${SES}" 
                    
                    for i in 'MCA_Pain_firstleveldesign_template_mpCON_oacV.fsf'; do # finds marker/flags in the template fsf 
                    sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                        -e 's@INPUT@'${INPUT}'@g' \
                        -e 's@NVOLS@'${NVOLS}'@g' \
                        -e 's@CON_MTX@'${CON_MTX}'@g' \
                        -e 's@ANAT@'${ANAT}'@g' \
                        -e 's@REGSTD@'${REGSTD}'@g' <$i> ${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_${SES}_Pain_firstleveldesign.fsf

                        # Runs the FSL analysis using the newly created fsf file                        
                        
                        echo "Running First Level Pain Stats for MCA${SUBJ}_Ses${SES} ..."               
                        feat ${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_${SES}_Pain_firstleveldesign.fsf
                        
                    done

                else
                    echo "No Motion Confounds in Pain scan MCA${SUBJ}_Ses${SES}"   # if needed, can change motion outlier threshold in fsl_motion_outliers script for desired metric values
                    echo Running in Preprocessing with simple GLM

                    for i in 'MCA_Pain_firstleveldesign_template_NOmpCon_oacV.fsf'; do # finds marker/flags in the template fsf 
                        sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                            -e 's@INPUT@'${INPUT}'@g' \
                            -e 's@NVOLS@'${NVOLS}'@g' \
                            -e 's@ANAT@'${ANAT}'@g' \
                            -e 's@REGSTD@'${REGSTD}'@g' <$i> ${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_${SES}_Pain_firstleveldesign.fsf

                            # Runs the FSL analysis using the updated fsf file                        
                            
                            echo "Running First Level Pain Stats for MCA${SUBJ}_Ses${SES} ..."               
                            feat ${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_${SES}_Pain_firstleveldesign.fsf
                    done
                fi             
            fi
        else 
            echo No Pain Data MCA${SUBJ}_Ses${SES}
        fi    
#   done
# done
 
echo All Runs Done
