# Get-AsaphLoginToken.ps1
# Get the Asaph login token, fetch by Connect-Asaph
# If you logged on to multiple Asaphs, each using Connect-Asaph, the module will remember each token. 
# You will have to specify the Asaph url to get its login token.
#
# Jan 2015
# If this works, this was written by Victor Vogelpoel (victor@victorvogelpoel.nl)
# If it doesn't work, I don't know who wrote this.

function Get-AsaphLoginToken
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('Url')]
        [Uri]$AsaphUrl
    )

    process
    {
        if ($null -ne $AsaphUrl)
        {
            # Find the cashed login token for the url
            $AsaphUrlText  = $AsaphUrl.ToString().TrimEnd('/', ' ')

            if (!($script:AsaphLoginTokens.ContainsKey($AsaphUrlText)))
            {
                # Cannot find login token for `"$AsaphUrl`"
                throw "Asaph site `"$AsaphUrl`" is not yet connected; please use Connect-Asaph to logon to this Asaph site first."
            }

            # Token is "cookieName:token, eg "asaphAdmin:827f41be9ea7d435044ca5397f4b20fb"
            return $script:AsaphLoginTokens[$AsaphUrlText]
        }
        else
        {
            # No Url was specified. Return the (only) token.
            # The $script:AsaphLoginTokens should contain exactly 1 token.
            switch ($script:AsaphLoginTokens.Count)
            {
                0		{ throw 'No Asaph sites are connected. Please use Connect-Asaph to logon to Asaph first.'; break }
                1		{ $script:AsaphLoginTokens.Values[0]; break}
                default	{ throw 'Multiple Asaph sites are connected. Please specify the Asaph URL.'; break }
            }
        }
    }
}
