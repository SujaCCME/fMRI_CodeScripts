 #!/bin/bash
#ref: https://wiki.biac.duke.edu/biac:fsl:guide

######### run this preprocessing script from MCA_FMRI/Public/Data directory; 

#loads the fsl program
#export FSLDIR=/usr/local/packages/fsl
#.${FSLDIR}/etc/fslconf/fsl.sh
 

#DATADIR=/Volumes/cerebro/Studies/MCA_FMRI/Public/Data
DATADIR=$PWD
label=$(date +"%m%d%Y_%H%M%S") #suffixes the output directory with timestamp
########################################################################################################################################################################################################################
 
# FEAT precessing check for each subject, session, and task

SUBJ=34 # for trial runs or individual runs
# SES=2 # for trial runs or individual runs
# TASK=1 # for trial runs or individual runs

for SUBJ in {7..116}
do
    # for SES in 1 2 
    # do
    #     for TASK in 1 2
    #     do  
                if [ -f "${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_corrected.nii.gz" ]; then
                    PROCESSED=false
                    for DIR in "${DATADIR}/FSL_Mem/Second_Level_Intermediate_Analyses/Gp_2lvl_MCA${SUBJ}_FE"_*_*.gfeat; do
                        if [ -d "${DIR}" ]; then
                                open ${DIR}/report_reg.html #opens the report.html file for the FEAT analysis
                                echo "MCA${SUBJ} Intermediate Analysis already done. Skipping to next gFEAT..."
                                PROCESSED=true
                                break
                        fi
                    done

                    if [ "${PROCESSED}" = false ]; then
                        echo "MCA${SUBJ} Intermediate Analysis NOT done..."

                        # fetches a text file with the input paths for the intermediate analysis
                        # FEATPATHFILE=${DATADIR}/FSL_Mem/Second_Level_Intermediate_Analyses/${SUBJ}_SecondLevel_Input_FEAT_Path.txt
                       
                        # INPUT=$(cat ${FEATPATHFILE})
                        INPUT1=${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Ses${SES}_Mem${TASK}_.......Stat.feat
                        INPUT2=
                        INPUT3=
                        INPUT4=
                        
                        #  function call to run feat
                        run_feat_fsf() # place to call 
      
                else 
                    echo "Memory Data MCA${SUBJ}_Ses${SES}_Mem${TASK} NOT fieldmap corrected. Skipping to next run..."
                fi
#         done
#     done
# done

# defining function for running feat
function run_feat_fsf()
{
    echo "Running FEAT for MCA${SUBJ}_Ses${SES}_Mem${TASK}..."


    ANAT=${DATADIR}/MCA${SUBJ}_Ses${SES}/T1/MCA${SUBJ}_T1_anat_brain.nii.gz
    REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
    CON_MTX=${DATADIR}/MCA${SUBJ}_Ses${SES}/Mem${TASK}_func/MCA${SUBJ}_Mtx.txt #EV matrix for combining Mem1 and Mem2 runs in paired sessions
    
    OUTPUTDIR=${DATADIR}/FSL_Mem/Second_Level_Intermediate_Analyses/Gp_2lvl_MCA${SUBJ}_FE_${label}
    
    echo "MCA${SUBJ} Intermediate Analysis being run..."

        for i in 'MCA_Mem_secondleveldesign_template_oacV.fsf'; do # finds marker/flags in the template fsf 
        sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
            -e 's@INPUT@'${INPUT}'@g' \
            -e 's@NVOLS@'${NVOLS}'@g' \
            -e 's@CON_MTX@'${CON_MTX}'@g' \
            -e 's@ANAT@'${ANAT}'@g' \
            -e 's@REGSTD@'${REGSTD}'@g' <$i> ${DATADIR}/FSL_Mem/Second_Level_Intermediate_Analyses/MCA${SUBJ}_secondleveldesign.fsf

            # runs the FSL analysis using the newly created fsf file               
                feat ${DATADIR}/FSL_Mem/Second_Level_Intermediate_Analyses/MCA${SUBJ}_secondleveldesign.fsf
                else 
                echo "Error running MCA${SUBJ}"
                fi
        done

    echo " MCA${SUBJ} Intermediate Analysis completed."

}