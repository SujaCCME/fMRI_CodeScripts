# python code for MRIcroGL to generate group figures condition-wise; Ref/Source: https://kathleenhupfeld.com/scripting-figures-in-mricrogl/
# Basic set-up 
import gl
import sys
gl.resetdefaults()

# Open background image
#gl.loadimage('C:/Users/admin/Documents/MRIcroGL_windows/MRIcroGL/Resources/standard/mni152.nii')
gl.loadimage('/Volumes/MRIcroGL/MRIcroGL.app/Contents/MacOS/Resources/standard/mni152.nii')

# Jagged (0) or smooth (1) interpolation of overlay  
gl.overlayloadsmooth(1)

# Set mosaic slices 
gl.mosaic("A H 0 -24 -20 -16 10 0; 10 20 30 40 50"); # add L+ to show slice labels; S X R 0 for 3D slice cuts

# Open overlay
gl.overlayload('/Volumes/cerebro/Studies/MCA_FMRI/Public/Data/FSL_Pain/GpAna-Sal-AvgPos_ME1+2_p05_05242024.gfeat/cope1.feat/thresh_zstat1.nii.gz')
# Set overlay display parameters; 1 indicates 1st overlay
gl.colorname(1,"4hot")
gl.minmax(2, 0, 8)
gl.opacity(1, 100)

gl.overlayload('/Volumes/cerebro/Studies/MCA_FMRI/Public/Data/FSL_Pain/GpAna-Sal-AvgNeg_ME1+2_p05_05292024.gfeat/cope2.feat/thresh_zstat1.nii.gz')
gl.colorname(2,"5winter")
gl.minmax(2, 0, 8)
gl.opacity(1, 100)

# Set the color bar options 
gl.colorbarposition(0)
gl.colorbarsize(0.05)

# Set mosaic slices 
gl.mosaic("A H 0 -24 -20 -16 10 0; 10 20 30 40 50"); #S X R 0

# Save the image 
gl.savebmp('/Volumes/cerebro/Studies/MCA_FMRI/Public/Data/FSL_Pain/MRIcroGL_PNGs/Sal_Avg_axial.png')

# close all overlays
gl.overlaycloseall()

#gl.quit()


