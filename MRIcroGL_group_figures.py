# python code for MRIcroGL to generate group figures condition-wise; Ref/Source: https://kathleenhupfeld.com/scripting-figures-in-mricrogl/
# Basic set-up 
import gl
gl.resetdefaults()

# Open background image
gl.loadimage('C:/Users/admin/Documents/MRIcroGL_windows/MRIcroGL/Resources/standard/mni152.nii')

# Jagged (0) or smooth (1) interpolation of overlay  
gl.overlayloadsmooth(1)
# Set mosaic slices 
gl.mosaic("A L+ H -0.1 -24 -20 -16 10 0; 10 20 30 40 50 S X R 0");
# Open overlay
gl.overlayload('/Volumes/cerebro/Studies/MCA_FMRI/Public/Data/FSL_Mem/Third_Level_Group_Analyses/Gp_3lvl_N138_ME12_07172024_Sal-Avg_SHK_cluster_z2_p05.gfeat/cope1.feat/thresh_zstat1.nii.gz')

# Set overlay display parameters; 1 indicates 1st overlay
gl.colorname(1,"4hot")
gl.minmax(2, 0, 8)
gl.opacity(1, 100)

gl.overlayload('/Volumes/cerebro/Studies/MCA_FMRI/Public/Data/FSL_Mem/Third_Level_Group_Analyses/Gp_3lvl_N138_ME12_07182024_Sal-AvgNeg_SHK_cluster_z2_p05.gfeat/cope1.feat/thresh_zstat1.nii.gz')
gl.colorname(2,"5winter")
gl.minmax(2, 0, 8)
gl.opacity(1, 100)

# Set the color bar options 
gl.colorbarposition(0)
gl.colorbarsize(0.05)

# Set mosaic slices 
gl.mosaic("A L+ H -0.1 -24 -20 -16 10 0; 10 20 30 40 50 S X R 0");

gl.labelsvisible(0)

# Save the image 
gl.savebmp('/Volumes/cerebro/Studies/MCA_FMRI/Public/Data/FSL_Mem/Third_Level_Group_Analyses/MRIcroGL_PNGs/Sal_Avg_SHK_MRIcroGL.png')
#gl.quit()


