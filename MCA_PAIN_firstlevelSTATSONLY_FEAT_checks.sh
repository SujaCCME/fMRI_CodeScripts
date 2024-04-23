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
 
# FEAT precessing check for each subject, session in Pain

# SUBJ=20 # (Next: 11, 12 for individual runs)
# SES=1 # for trial runs or individual runs

for SUBJ in {31..116}
do
    for SES in 1 2 
    do
                if [ -f "${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_Ses${SES}_Pain_corrected.nii.gz" ]; then
                PROCESSED=false        
                    for DIR in "${DATADIR}/FSL_Pain/First_Level_Subj_Analyses/${SUBJ}-${SES}_Pre_"*_*.feat; do
                        if [ -d "${DIR}/${SUBJ}-${SES}_StatsOnly.feat" ]; then
                            open ${DIR}/${SUBJ}-${SES}_StatsOnly.feat/report.html
                            echo "Pain Data MCA${SUBJ}_Ses${SES}_Pain already processed with full confounds set. Skipping to next FEAT..."
                            PROCESSED=true
                            break

                        else
                            echo "Pain Data MCA${SUBJ}_Ses${SES}_Pain NOT processed with full confounds..."
                            INPUT=${DIR}/filtered_func_data_reg
                        fi
                        
                        if [ "${PROCESSED}" = false ]; then

                            # echo "Pain Data MCA${SUBJ}_Ses${SES}_Pain NOT processed with full confounds..."
                            # INPUT=${DIR}/filtered_func_data_reg.nii.gz

                            printf "Registered Functional Data Input: ${INPUT}\n"

                            NVOLS=$(fslnvols ${INPUT}) # updates fsf file with number of vols/timepoints for the fmri run in this session from FSLNVOLS fslutil command
                            NVXLS=$(fslstats ${INPUT} -V | awk '{print $1}') # updates fsf file with number of voxels for the fmri run in this session from FSLSTATS command; the first element of the array stored from $(fslstats ${INPUT})
                            REGSTD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
                            CON_MTX=${DIR}/filtered_func_data_reg_mp6_fdrms1pt5_CmCrn5.txt #confounds matrix from motion parameters, motion outliers fdrms>1.5mm, n5 CompCor
                            
                            OUTPUTDIR=${DIR}/${SUBJ}-${SES}_StatsOnly.feat
                            
                            echo "Pain Data MCA${SUBJ}_Ses${SES}_Pain being processed..."

                        
                                    #replacing subject-specific EVs to the fsf file IF OUTLIERS WERE DETECTED
                                    if [ -f "$CON_MTX" ]; then
                                        echo "Found Confounds Matrix : MCA${SUBJ}_Ses${SES}_Pain" 

                                        for i in 'MCA_Pain_StatsOnly_design_template_mpCON_oacV.fsf'; do # finds marker/flags in the template fsf 
                                            sed -e 's@OUTPUTDIR@'${OUTPUTDIR}'@g' \
                                                -e 's@INPUT@'${INPUT}'@g' \
                                                -e 's@NVOLS@'${NVOLS}'@g' \
                                                -e 's@NVXLS@'${NVXLS}'@g' \
                                                -e 's@CON_MTX@'${CON_MTX}'@g' \
                                                -e 's@REGSTD@'${REGSTD}'@g' <$i> ${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_${SES}_Pain_firstlevelSTATSONLYdesign.fsf
                                                
                                                # runs the FSL analysis using the newly created fsf file                      
                                            
                                                echo "Running First Level Stats for MCA${SUBJ}_Ses${SES}_Pain with full confound set..."    
                                                feat ${DATADIR}/MCA${SUBJ}_Ses${SES}/Pain_func/MCA${SUBJ}_${SES}_Pain_firstlevelSTATSONLYdesign.fsf

                                                echo "Pain Data MCA${SUBJ}_Ses${SES}_Pain processed with full confound set."
                                                
                                                # copy reg_standard folders to the STATSONLY output directory
                                                cp -r ${OUTPUTDIR}/reg_standard ${OUTPUTDIR}/reg_standard
                                                echo "Copied reg_standard folder to ${OUTPUTDIR}... Redundant Copy to avoid errors in the second/third level analysis"
                                         done                                           

                                    else
                                        echo "Confounds set missing - ${DIR}"   
                                        echo "${DIR} full confound set NOT processed . Skipping to next run..."
                                    fi
                            
                        else
                            echo "Pain Data MCA${SUBJ}_Ses${SES}_Pain already processed. Skipping to next run..."
                        fi
                    done 

                else 
                    echo Pain Data MCA${SUBJ}_Ses${SES}_Pain NOT found. Skipping to next run...
                fi
    done
done