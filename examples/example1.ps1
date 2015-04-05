# example1.ps1
# Example use of the Dramatic Asaph module
# If this script works, it was written by Victor Vogelpoel (victor@victorvogelpoel.nl
# If not, I do not know who wrote this.


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
Publish-AsaphImage -ImageUrl 'http://fc03.deviantart.net/fs71/i/2013/054/7/d/about_the_girl_with_eyes_made_of_fire_by_laurazalenga-d5vpohz.jpg' -ImageTitle 'Beauty' -ImageSiteUrl '' -AsaphUrl $AsaphUrl

# Results:
# ImageTitle   ImageUrl                          ImageSiteUrl                 PublishResult                                                      
# ----------   --------                          ------------                 -------------                                                      
# Beauty       http://fc03.deviantart.net/fs7...                              SuccessImageIsPosted                                       



# Note that the 'Publish-Image' cmdlet returns a custom object designating the publish result.
# In the following example two images were posted; the first had already been posted:
# ImageTitle   ImageUrl                          ImageSiteUrl                 PublishResult                                                      
# ----------   --------                          ------------                 -------------                                                      
# Beauty       http://fc03.deviantart.net/fs7...                              SuccessImageWasAlreadyPosted                                       
# Test         https://ppcdn.500px.org/352663... https://500px.com/flow#focus SuccessImageIsPosted
