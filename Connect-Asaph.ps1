# Connect-Asaph.ps1
# Login into Asaph with credentials or a login token
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


function Connect-Asaph
{
    [CmdletBinding(DefaultParameterSetName='Credential')]
    param
    (
        [Parameter(Mandatory=$true, position=0, ParameterSetName='Credential', helpmessage=' The URL of the Asaph site.')]
        [Parameter(Mandatory=$true, position=0, ParameterSetName='Token', helpmessage=' The URL of the Asaph site.')]
        [ValidateNotNull()]
        [Alias('Url')]
        [Uri]$AsaphUrl,

        [Parameter(Mandatory=$true, position=1, ParameterSetName='Credential', helpmessage='PSCredential to use to log into the Asaph site.')]
        [ValidateNotNull()]
        [PSCredential]$Credential,

        [Parameter(Mandatory=$true, position=1, ParameterSetName='Token', helpmessage='Login token to use to log into the Asaph site.')]
        [ValidateNotNullOrEmpty()]
        [Alias('Token', 'LogonToken')]
        [string]$AsaphLoginToken,

        [Parameter(Mandatory=$false, helpmessage='Return the logon token. For example, you may wish to store the login token for later use.')]
        [switch]$Passthru
    )

    $asaphUrlText	= $($AsaphUrl.ToString().TrimEnd('/', ' '))
    $asaphAdminUri	= [Uri]"$asaphUrlText/admin/"

    if ($PSCmdlet.ParameterSetName -eq 'Credential')
    {
        # Credentials were specified.

        try
        {
            $response = Invoke-WebRequest -Uri $asaphAdminUri -SessionVariable loginsession
            #$response.Content
        }
        catch
        {
            throw "Failed to login into Asaph: error while requesting page at `"$asaphAdminUri`"."
        }

        if ($null -eq $response -eq $null -or $response.StatusCode -ne 200 -or $response.Forms.Count -eq 0 -or !$response.Forms[0].Fields.ContainsKey('name') -or !$response.Forms[0].Fields.ContainsKey('pass') -or !$response.Forms[0].Fields.ContainsKey('dologin') )
        {
            throw "Site at `"$AsaphUrl`" is not Asaph or cannot access Asaph admin page."
        }

        $form              		= $response.Forms[0]
        $form.Fields['name']	= $Credential.Username
        $form.Fields['pass']	= $Credential.GetNetworkCredential().Password
    
        Write-Verbose "Posting username and password to `"$asaphAdminUri`"..."
        $response 				= Invoke-WebRequest -Uri $asaphAdminUri -WebSession $loginsession -Method Post -Body $form.Fields

        if ($null -eq $response -or $response.StatusCode -ne 200 -or $response.content -like '*The name or password was not correct!*')
        {
            throw "Incorrect name or password while attempting logging on to Asaph site at `"$asaphUrlText`""
        }

        #$cookieName = "$($AsaphUrl.Segments | select -Last 1)Admin"  # get the directory name of the asaph installation, which is the cookieName + "Admin"
        $cookieName = 'asaphAdmin'
        $cookie     = $loginsession.Cookies.GetCookies($asaphAdminUri)[$cookieName]
        if ($null -eq $cookie)
        {
            throw "Missing logon token cookie in logon response at Asaph site $asaphUrlText"
        }

        $asaphLoginTokenFromCookie = $cookie.Value
        if ($null -eq $asaphLoginTokenFromCookie)
        {
            throw "Missing logon token cookie in logon response at Asaph site $asaphUrlText"
        }

        $script:AsaphLoginTokens[$asaphUrlText]	= $asaphLoginTokenFromCookie
        $AsaphLoginToken                        = $asaphLoginTokenFromCookie
    }
    else
    {
        # A token was specified. Ensure validity.

        $loginCookie	= New-Object System.Net.Cookie('asaphAdmin', $AsaphLoginToken, $asaphPostUri.AbsolutePath, $asaphPostUri.Host)

        # Now prepare the login cookie for the request
        $cc				= New-Object System.Net.CookieContainer 
        $session		= New-Object Microsoft.PowerShell.Commands.WebRequestSession  
        $cc.Add($loginCookie)
        $session.Cookies = $cc  

        try
        {
            $response = Invoke-WebRequest -Uri $asaphAdminUri -WebSession $session
        }
        catch
        {
            throw "Failed to login into Asaph: error while requesting page at `"$asaphAdminUri`"."
        }

        if ($null -eq $response -eq $null -or $response.StatusCode -ne 200 -or $response.Content -like '*<title>Login: Asaph</title>*')
        {
            throw "Failed to login into Asaph with specified logon token; please log on with credentials (instead of token)."
        }

		# Cache the token in memory
        $script:AsaphLoginTokens[$asaphUrlText] = $AsaphLoginToken
    }

    if ($Passthru)
    {
        Write-Output $AsaphLoginToken
    }


<#
.SYNOPSIS
    Login to an Asaph site using the specified credentials or login token.

.DESCRIPTION
    Connect-Asaph logs into the specified Asaph site with the specified credentials.
    The Asaph site Url and logon token is cached in memory in the module. Publish-AsaphImage uses
    this logon token when posting an image to the Asaph site.

.PARAMETER AsaphUrl
    The URL of the Asaph site.

.PARAMETER Credential
    PSCredential to use to log into the Asaph site.

.PARAMETER AsaphLoginToken
    Login token to use to log into the Asaph site.
    You may have saved the token from an earlier session and want to reuse it.

.PARAMETER Passthru
    Return the logon token. For example, you may wish to store the login token
    for later use.

.EXAMPLE
    Connect-Asaph -AsaphUrl 'http://domain.com/asaph' -Credential (Get-Credential)

    Asks for credentials and uses this to log into the Asaph site at http://domain.com/asaph.

.EXAMPLE
    Connect-Asaph -AsaphUrl 'http://domain.com/asaph' -AsaphLoginToken '0b6cb84e0680d78bd63832c668560c0b'

    Log in to http://domain.com/asaph with login token '0b6cb84e0680d78bd63832c668560c0b'.

.NOTES
   Each time you use Connect-Asaph with credentials to log into an Asaph site, Asaph calculates 
   a new logon token, which is returned in a cookie. This token is each time different.

.LINK
    Publish-AsaphImage
#>


}
