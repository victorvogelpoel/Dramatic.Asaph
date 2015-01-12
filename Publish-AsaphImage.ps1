# Publish-AsaphImage.ps1
# Post an image to the Asaph site.
# Jan 2015
# If this works, this was written by Victor Vogelpoel (victor@victorvogelpoel.nl)
# If it doesn't work, I don't know who wrote this.
#
# This program is free software; you can redistribute it and/or modify it under the terms 
# of the GNU General Public License as published by the Free Software Foundation; either 
# version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program; 
# if not, write to the Free Software Foundation, Inc., 
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.



function Publish-AsaphImage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Uri]$ImageUrl,

        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [String]$ImageTitle= '',

        [Parameter(Mandatory=$false)]
        [Alias('Referer')]
        [String]$ImageSiteUrl = '',

        [Parameter(Mandatory=$false)]
        [Uri]$AsaphUrl
    )

    # Make sure we're logged on to the Asaph site; Connect-Asaph must have been used
    #Assert-AsaphLoggedOn -AsaphUrl $AsaphUrl

    # Get the Logon token from the local cache
    $logonToken = Get-AsaphLoginToken -AsaphUrl $AsaphUrl

    if ($null -eq $AsaphUrl)
    {
        $AsaphUrl = [Uri]($script:AsaphLoginTokens.Keys[0]).ToString()
    }

    $AsaphUrlText  = $AsaphUrl.ToString().TrimEnd('/', ' ')
    $asaphAdminUri = [Uri]"$AsaphUrlText/admin"
    $asaphPostUri  = [Uri]"$AsaphUrlText/admin/post.php"

    $loginCookie   = New-Object�System.Net.Cookie('asaphAdmin',�$logonToken,�$asaphPostUri.AbsolutePath,�$asaphPostUri.Host)

    # Now prepare the login cookie for the request
    $cc�=�New-Object�System.Net.CookieContainer�
    $session�=�New-Object�Microsoft.PowerShell.Commands.WebRequestSession��
    $cc.Add($loginCookie)
    $session.Cookies�=�$cc��

    $asaphItemParams = @{
        'xhrLocation'	= ''
        'title' 		= $ImageTitle
        'image' 		= $ImageUrl
        'referer' 		= $ImageSiteUrl
        'post' 			= 'post'
    }

    try
    {
        # Invoke the publish image command on Asaph
        Write-Verbose "Posting the image to the Asaph site..."
        $response = Invoke-WebRequest -Uri $asaphPostUri -WebSession $session -Method Post -Body $asaphItemParams
        if ($response)
        {
            $result = [PSCustomObject]@{
                'ImageTitle' 	= $ImageTitle
                'ImageUrl' 		= $ImageUrl
                'ImageSiteUrl' 	= $ImageSiteUrl
                'PublishResult'	= [AsaphPublishResult]::SuccessImageIsPosted
            }

            switch -wildcard ($response.Content)
            {

                '*Asaph_PostSuccess*' 				{ Write-Verbose "Image was posted!"; $result.PublishResult = 'SuccessImageIsPosted'; break }

                '*This image was already posted!*'	{ Write-Verbose 'Image was already posted!'; $result.PublishResult = 'SuccessImageWasAlreadyPosted' ;break }

                '*Couldn''t load the image!*'
                {
                    Write-Verbose 'Couldn''t load the image!'
                    $result.PublishResult = 'FailCouldntLoadTheImage'
                    # throw "Failed to publish image `"$ImageUrl`"; Asaph couldn't load the image from its source."
                    Break
                }

                '*Couldn''t create a thumbnail of the image!*'
                {
                     Write-Verbose 'Couldn''t load the image!'
                     $result.PublishResult = 'FailCouldntCreateThumbnailOfImage'
                     #throw "Failed to publish image `"$ImageUrl`"; Asaph could load the image from its source, but couldn''t create a thumbnail of the image!."
                     Break
                }

                default 							{ $result.PublishResult = 'FailUnknownError'; break }
            }

            Write-Output $result
        }
        else
        {
            throw "Failed to publish image `"$ImageUrl`"; something went wrong while invoking the Asaph post page, because the response is empty."
        }
    }
    catch
    {
        throw "Failed to publish image `"$ImageUrl`" to Asaph site `"$AsaphUrl`": $($_.Exception.Message)"
    }
}

