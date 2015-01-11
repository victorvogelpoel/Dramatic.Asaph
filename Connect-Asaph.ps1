function Connect-Asaph
{
    [CmdletBinding(DefaultParameterSetName='Credential')]
    param
    (
        [Parameter(Mandatory=$true, position=0, ParameterSetName='Credential')]
        [Parameter(Mandatory=$true, position=0, ParameterSetName='Token')]
        [ValidateNotNull()]
        [Alias('Url')]
        [Uri]$AsaphUrl,

        [Parameter(Mandatory=$true, position=1, ParameterSetName='Credential')]
        [ValidateNotNull()]
        [PSCredential]$Credential,

        [Parameter(Mandatory=$true, position=1, ParameterSetName='Token')]
        [ValidateNotNullOrEmpty()]
        [Alias('Token', 'LogonToken')]
        [string]$AsaphLoginToken,

        [Parameter(Mandatory=$false)]
        [switch]$Passthru
    )

    $asaphUrlText = $($AsaphUrl.ToString().TrimEnd('/', ' '))
    $asaphAdminUri = [Uri]"$asaphUrlText/admin/"

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

        $form = $response.Forms[0]
        $form.Fields['name'] = $Credential.Username
        $form.Fields['pass'] = $Credential.GetNetworkCredential().Password
    
        Write-Verbose "Posting username and password to `"$asaphAdminUri`"..."
        $response = Invoke-WebRequest -Uri $asaphAdminUri -WebSession $loginsession -Method Post -Body $form.Fields

        if ($null -eq $response -or $response.StatusCode -ne 200 -or $response.content -like '*The name or password was not correct!*')
        {
            throw "Incorrect name or password while attempting logging on to Asaph site at `"$asaphUrlText`""
        }

        $asaphLoginTokenFromCookie = $loginsession.Cookies.GetCookies($asaphAdminUri)['asaphAdmin'].Value
        if ($null -eq $asaphLoginTokenFromCookie)
        {
            throw "Missing logon token cookie in logon response at Asaph site $asaphUrlText"
        }

        $script:AsaphLoginTokens[$asaphUrlText] = $asaphLoginTokenFromCookie

        $AsaphLoginToken = $asaphLoginTokenFromCookie
    }
    else
    {
        # A token was specified. Ensure validity.

        $loginCookie   = New-Object System.Net.Cookie('asaphAdmin', $AsaphLoginToken, $asaphPostUri.AbsolutePath, $asaphPostUri.Host)

        # Now prepare the login cookie for the request
        $cc = New-Object System.Net.CookieContainer 
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession  
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

        $script:AsaphLoginTokens[$asaphUrlText] = $AsaphLoginToken
    }

    if ($Passthru)
    {
        Write-Output $AsaphLoginToken
    }
}
