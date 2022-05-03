# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 14:42:32 2020

@author: xuchun
"""

import matplotlib.pyplot as plt
import numpy as np
import h5py

# import data 
group = ["NAc","NAc_Amy", "Amy",  "Amy_mPFC", "mPFC","mPFC_NAc"]
filesucrose=r"\\10.10.46.135\Lab_Members\XuChun\Manuscript\02 IBIST\Figures\Linked figures\retro_GCamp\photometry_result\sucrose\myfile.h5"
filewater=r"\\10.10.46.135\Lab_Members\XuChun\Manuscript\02 IBIST\Figures\Linked figures\retro_GCamp\photometry_result\water\myfile.h5"
fileshock=r"\\10.10.46.135\Lab_Members\XuChun\Manuscript\02 IBIST\Figures\Linked figures\retro_GCamp\photometry_result\first_shock\myfile.h5"
filesave=r"\\10.10.46.135\Lab_Members\XuChun\Manuscript\02 IBIST\Figures\Linked figures\retro_GCamp\photometry_result\myfile.h5"

# ======  sucrose ===============
filename=filesucrose
h5 = h5py.File(filename,'r')
s =  h5['peak'][0:6].tolist()
s = s+ [s[0]]
s2=h5['mean'][0:6].tolist() # mean
s2=s2+[s2[0]]
h5.close()
peaksucrose=np.divide(s,max(s))
meansucrose=np.divide(s2,max(s2))
# ======  water ===============
filename=filewater
h5 = h5py.File(filename,'r')
s =  h5['peak'][0:6].tolist()
s = s+ [s[0]]
s2=h5['mean'][0:6].tolist() # mean
s2=s2+[s2[0]]
h5.close()
peakwater=np.divide(s,max(s))
meanwater=np.divide(s2,max(s2))
# ======  shock ===============
filename=fileshock
h5 = h5py.File(filename,'r')
s =  h5['peak'][0:6].tolist()
s = s+ [s[0]]
s2=h5['mean'][0:6].tolist() # mean
s2=s2+[s2[0]]
h5.close()
peakshock=np.divide(s,max(s))
meanshock=np.divide(s2,max(s2))



# ======== plot the peak =========== 
# Initialise the spider plot by setting figure size and polar projection
plt.figure(figsize=(10, 6))
plt.subplot(polar=True)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
theta = np.linspace(0, 2 * np.pi, len(s))
# Arrange the grid into number of sales equal parts in degrees
lines, labels = plt.thetagrids(range(0, 360, int(360/len(group))), (group))
p1=plt.plot(theta, peakshock,'r') 
p2=plt.plot(theta, peakwater,'b') 
p3=plt.plot(theta, peaksucrose,'gold')
##p4=plt.plot(theta, peakwateromission,'k') 
#plt.ylim(-1,1)
# Add legend and title for the plot
plt.legend(labels=('Shock', 'Water', 'Sucrose','Water Omission'), loc='best')
plt.title('Peak ') 
plt.savefig(filesave.replace(".h5","Peak_Overlay_peak.pdf"), format='pdf')
plt.savefig(filesave.replace(".h5","Peak_Overlay_peak.png"), format='png')
plt.show() 

# ======== plot the mean ===========
plt.figure(figsize=(10, 6))
plt.subplot(polar=True)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
theta = np.linspace(0, 2 * np.pi, len(s))
# Arrange the grid into number of sales equal parts in degrees
lines, labels = plt.thetagrids(range(0, 360, int(360/len(group))), (group))
plt.plot(theta, meanshock,'r') 
plt.plot(theta, meanwater,'b') 
plt.plot(theta, meansucrose,'gold')
##plt.plot(theta, meanwateromission,'k') 
#plt.ylim(-1,1)
# Add legend and title for the plot
plt.legend(labels=('Shock', 'Water', 'Sucrose','Water Omission'), loc=1)
plt.title('Mean ') 
plt.savefig(filesave.replace(".h5","Peak_Overlay_Mean.pdf"), format='pdf')
plt.savefig(filesave.replace(".h5","Peak_Overlay_Mean.png"), format='png')
plt.show()


