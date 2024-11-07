---
title: How I recovered a corrupt SD Card
date: 2024-11-06
tags:
  - Linux
  - Fixes
---

  

# How I recovered corrupt data with DDRescue and PhotoRec

Halloween was about a week ago and my friend Sade had used their Cannon point and shoot digital camera to take some party pictures. Somehow the photos which were stored on a 16 gig SD card became corrupted. When the card was plugged into an adapter, the phone did not display anything and alternatively it was not recognized when inserted into our friends MacBook. 

<CustomImage src="https://raw.githubusercontent.com/michael-kudrik/BlogPosts/main/images/SeaScene/A_Scene_at_the_Sea_004.jpg" alt="Surfboard next to trash" />

After hearing this I figured I might as well fool around with it and see if I could recover some if not all of the data.  I spent a few hours researching different methods and programs to use. It was imperative that I knew what I was doing as one wrong step can easily destroy an entire drive. 

I eventually settled on two software packages that I would install on my spare laptop which was running a Linux distribution. If you have read any of my other blogs you'll know that I am a huge [FOSS](https://en.wikipedia.org/wiki/Free_and_open-source_software) advocate. I wanted to find something that was free of cost and had preferably been around for a while with code that is open source and trusted. 

The first software that I settled on was [Ddrescue](https://www.gnu.org/software/ddrescue/), a data recovery tool that works by copying data from one device (in this case the SD card) to another (my Linux laptop). Ddrescue attempts to read through the different memory sectors and create an image of all the good parts. I will get into more detail later. 

The second software I chose was also available under the GNU license and was free to download. [PhotoRec](https://www.cgsecurity.org/wiki/PhotoRec) uses [file carving](https://en.wikipedia.org/wiki/File_carving) to recover lost files from various memory types. It worked very well in my case but if I had to do this again I might instead opt for [R-Photo](https://www.r-undelete.com/free_photo_recovery/Download.shtml) as I have read it is usually the preferred software.

When it came to plugging in my SD card I made sure to directly SATA connect the card into my laptop. This is because a USB adapter may have slowed down the process. 

## Step 1: Ensure the drive is detected

Before I could get started with any recovery I obviously needed to make sure that the SD card was actually detected by the laptop, otherwise I might not be able to continue with the process. 

1. First I used the command `lsblk` which lists information about all the available block devices. 
	- If this works correctly you should see something like: `/dev/mmcblk0` (note this down) as well as other devices or drives. Depending on how your filesystem is set up you might see a `/sda0` or etc. 
	- If the SD card does not appear then we have a problem. This is unfortunately what happened in my case.

If you do not see the card then you should probably start troubleshooting. The cause of this can vary greatly and unfortunately the SD card might be beyond recovery.

In my case I was able to force a rescan of device's by running the following:
```bash
sudo echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan
sudo partprobe
```
Essentially the first command rescans SCSI devices by sending a signal to all the SCSI hosts asking to rescan for new devices. The second part, `partprobe` tells the system to re-read the partition table of all block devices.  For me this worked and I was now able to see the block device listed as `/dev/mmcblk0`😀.

2. You can also use the command `dmesg` which shows kernel-related messages that are stored in the kernel ring buffer. It contains information on hardware, drivers, and any kernel module messages that are generated during system startup. 
	- This actually came in handy when diagnosing my issue because it gave me the following error message which simply told me that the card was having errors when I started up the computer:
```bash
-mmc0: Card stuck being busy! __mmc_poll_for_busy 
mmc0: error -110 whilst initializing SD card
```

## Step 2: Prepare tools

The next step is to install the **ddrescue** and **testdisk** packages from whatever Linux package manager you use. 

For Debian based machines run:
`sudo apt install ddrescue testdisk`

And for Arch based machines:
`sudo pacman -S ddrescue testdisk`

Now we can go ahead and set up a place for our recovery directory that way we can place the disk image there.
```bash
mkdir ~/sd_recovery
cd ~/sd_recovery
```

After we have done this we can proceed with ddrescue.

## Step 3: Use ddrescue to create an image

Before you begin I should mention that you should take a look at the ddrescue [documentation](https://www.gnu.org/software/ddrescue/manual/ddrescue_manual.html#Invoking-ddrescuelog) which explains what each of the options do in the command. 

Lets get started. In your terminal type out the following command:
```bash
sudo ddrescue /dev/mmcblk0 ~/sd_recovery/sdcard_backup.img ~/sd_recovery/rescue.log
```

Where `/dev/mmcblk0` is the correct path for the drive you are trying to recover. It is **imperative** that you get this right otherwise you risk damage. 

`~/sd_recovery/sdcard_backup.img` is the path to create the image file in. You should use the folder we created in step 2. 
`~/sd_recovery/rescue.log` specefies the location for the log file which is very important.

According to a from post from Jared of [data-medics](data-medics.com), the log file is  "a list of sector ranges which have been copied, skipped, marked as bad, etc. which the program will use on successive passes to get as much data as possible."

After running the command you should 