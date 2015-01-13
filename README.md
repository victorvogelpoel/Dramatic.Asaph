## PowerShell module for Asaph ##

Dramatic.Asaph provides a PowerShell way to publish images to micro blogging system Asaph.

Copyright (C) 2015 Victor Vogelpoel - Dramatic Development

### License ###

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


**IMPORTANT: This module is still under development.**

### TODO ###
- Implement Publish-AsaphSite


### Asaph? ###
Asaph is a PHP/MySQL based collection micro blogging system by PhobosLab. It is a small CMS that can pick images and text from web pages.
You can find more information at [http://phoboslab.org/projects/asaph](http://phoboslab.org/projects/asaph).

Asaph has no API, so this PowerShell module requests, scrapes and posts the Asaph pages. 


### Why Module "Dramatic.Asaph"? ###
I collect great images from photo sites and use various devices and apps to visit these sites. The Asaph picker can only be used on a PC; sometimes mailing myself the url of the photo page is the only thing I can resort to on other devices. An automated workflow enables me to read the photo page urls from my mail box and use the module's **Publish-AsaphImage** to register the photo into my Asaph sites.

### "Dramatic"? ###
It's short for Dramatic Development, my coding brand.


## Installation ##
Copy the files into directory "~\WindowsPowerShell\Modules\Dramatic.Asaph". You may need to create the directory first: 

1. In directory "~\Documents" (C:\Users\\[YOURACCOUNT]\Documents), create a folder "WindowsPowerShell", if it is not there already.
2. In directory "~\Documents\WindowsPowerShell", create folder "Modules", if it is not there already.
3. In directory "~\Documents\WindowsPowerShell\Modules\", create directory "Dramatic.Asaph". 
4. Copy the files from this GIT repository to folder "~\Documents\WindowsPowerShell\Modules\Dramatic.Asaph".


## Features ##
- Logging in to an Asaph site with specified credentials: **Connect-Asaph**.
- Logging in to multiple Asaph sites; the module registers and caches the logon tokens in memory.
-  Publishing an image (eg giving Asaph an image url to download); Asaph will download the image from the image url and register it: **Publish-AsaphImage**. 
- Publish-AsaphImage returns the (enum) result of the publish action: SuccessImageIsPosted, SuccessImageWasAlreadyPosted, FailCouldntLoadTheImage, FailCouldntCreateThumbnailOfImage or FailUnknownError
-  Handles both http and https image urls.
-  Limitation: image url must be accessible without the need of logging on the source site.
 


## Usage ##
    
	# Advise: create a separate user account in Asaph web administration first, 
	# which is to be used by this script below (for example: user "PowerShellbot").
	# Enter these credentials when Get-Credentials below asks for it. 

	# load the module
	Import-Module 'Dramatic.Asaph'
	
	# This is the Asaph site (do not specify "/admin"!) 
	$asaphUrl = 'http://domain.com/asaph'

	# Ask credentials for Asaph; enter the credential for the separate user account.
	$credentials = Get-Credentials

	# Login to the Asaph site with the credentials
	Connect-Asaph -AsaphUrl $asaphUrl -Credential $credentials

	# Publish the specified image url to Asaph...
    # Asaph will download the image and register it.
	Publish-AsaphImage -ImageUrl 'http://fc03.deviantart.net/fs71/i/2013/054/7/d/about_the_girl_with_eyes_made_of_fire_by_laurazalenga-d5vpohz.jpg' -ImageTitle 'Test' -ImageSiteUrl '' -AsaphUrl $AsaphUrl

The Publish-Image cmdlet returns a custom object designating the publish result; in the following example two images were posted while the second had already been posted:

    ImageTitle   ImageUrl                          ImageSiteUrl                 PublishResult                                                      
	----------   --------                          ------------                 -------------                                                      
	Beauty       http://fc03.deviantart.net/fs7...                              SuccessImageIsPosted                                       
	Test         https://ppcdn.500px.org/352663... https://500px.com/flow#focus SuccessImageWasAlreadyPosted

## Resources ##

- [Asaph by PhobosLab](http://phoboslab.org/projects/asaph)
- Victor's vCard site [http://victorvogelpoel.nl](http://victorvogelpoel.nl)
- [Victor's GitHub](https://github.com/victorvogelpoel) 
