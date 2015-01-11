

function Disconnect-Asaph
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [Alias('Url')]
        [Uri]$AsaphUrl
    )

    $asaphUrlText = $AsaphUrl.ToString().TrimEnd('/', ' ')
    $asaphAdminUri = [Uri]"$asaphUrlText/admin/"

    # Remove the cached token for the specified site
    $script:AsaphLoginTokens.Remove($asaphUrlText)
}
