

function Assert-AsaphLoggedOn
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false)]
        [Alias('Url')]
        [Uri]$AsaphUrl
    )

    try
    {
        Get-AsaphLoginToken -AsaphUrl $AsaphUrl
    }
    catch
    {
        throw "Not logged on; use Connect-Asaph first to log on to an Asaph site."
    }
}