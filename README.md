# (Semi) Automatic Spike Sorting Project

## Summary
This project is a sorter program that semi-automatically sorts neuron action 
potential waveforms.

## Details
The program sorts on a receptive field basis, termed "superblock." Each
superblock is sorted on a channel basis.

This program is semi-automatic because it requires user input on alignment
options and the number of units present in a superblock/channel.

## Procedure
* Double-click `sorter.m` to open MATLAB in the project root directory
* Run `sorter.m` either from the MATLAB command line or through the editor's
  'Run' button.
* The user will be prompted with several dialogs:

    1. Select tank
    2. Select feature
    3. Select sorting algorithm
    4. Select data export directory
    
    Once these are completed, the program will create superblocks
    through automatic receptive field detection. This is expected to
    take a while, especially for tanks whose blocks contain multiple
    receptive fields. After this, the program will begin sorting.

* For each superblock:
    1. For each channel:
    
        a. Choose alignment option ('max' or 'min') and maximum shift
           (default: 5 ticks).
           
        b. Choose number of units present in the feature space.

        The program will then sort the channel and create superspiketrain
        objects as well as figures for later inspection. This process will
        take some time to complete.
        
* Validation:

    The results of a tank sort are saved to a directory wnose name is the
    same as the tank's name. This directory is located in the directory 
    the user selected for data export previously.
    
    Within the tank's sort result directory, the `Figures/` directory
    contains useful figures for sorting evaluation. The `SST_obj/` directory
    contains the generated superspiketrain objects.

## Setup

Currently, this project is private, so the repository must be manually copied
to its new location. In the case this project is cloned from GitHub, it may
not necessarily work out of the box.

###Requirements

#### Essential

These requirements must be satisfied for the program to work:

* MATLAB 2014 or later
* MATLAB Toolboxes

Also required is software and drivers from Tucker-Davis Technologies
([link])(http://tdt.com/downloads.html). Specifically, the following software
are required:

* TDT Drivers/RPvdsEx
* ActiveX Controls
* OpenEx
* OpenDeveloper

Note that installation requires a TDT license.

#### Secondary

These are not required for the core sorter program to function. However, some
scripts will not work without them.

* [MATLAB Offline Files SDK](http://plexon.com/software-downloads): Go to the
"OmniPlex and MAP Offline" tab

Make a `code/` directory in the project root if it doesn't exist. Extract the
zip file there.

## Other Details

### Legacy code

The `legacy/` directory contains code that was developed while working on the
project. The code is not used by the sorter program and may be useful as a
reference, as many current sorter files were inspired by them.

### Outside code

Put all outside MATLAB code in the `code/` directory. Note that `.gitignore`
is set up to ignore that directory. This directory is generally intended
for outside code that is large in size and not intended for version control.
Otherwise, the `utils/` directory can be used instead. See "Credits" for 
more information.

### Credits

The project includes (possibly modified) code that has been written by others
or heavily borrowed from. Most of these files are located in the `utils/`
directory. Generally these files are considered essential to the sorter
program.


## Notes

This project was a summer project sponsored by the Kresge Hearing Research
Institute (KHRI) at the University of Michigan, Ann Arbor.

Author: Daniel Xu

Faculty Sponsor: Susan Shore, PhD.

Mentor: David Martel

**Last updated:** 2015-08-06
