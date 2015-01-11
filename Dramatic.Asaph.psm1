# Dramatic.Asaph.psm1
# Module for Phoboslab Asaph micro blogging system (http://phoboslab.org/projects/asaph)
# Jan 2015
# If this works, this was written by Victor Vogelpoel (victor@victorvogelpoel.nl)
# If it doesn't work, I don't know who wrote this.


#requires -version 3.0 
Set-PSDebug -Strict
Set-StrictMode -Version Latest


# Allways stop at an error
$global:ErrorActionPreference 	= "Stop"


#----------------------------------------------------------------------------------------------------------------------
# Set variables
$script:thisModuleDirectory			= $PSScriptRoot								# Directory Modules\Dramatic.Asaph\

#----------------------------------------------------------------------------------------------------------------------
# Cache for the login tokens
$script:AsaphLoginTokens = @{}


Add-Type -TypeDefinition @"
   public enum AsaphPublishResult
   {
      SuccessImageIsPosted,
      SuccessImageWasAlreadyPosted,
      FailCouldntLoadTheImage,
      FailCouldntCreateThumbnailOfImage,
      FailUnknownError
   }
"@


#----------------------------------------------------------------------------------------------------------------------
# Dot source any related scripts and functions in the same directory as this module
$ignoreCommandsForDotSourcing = @(
)

Get-ChildItem $script:thisModuleDirectory\*.ps1 | foreach { 

	if ($ignoreCommandsForDotSourcing -notcontains $_.Name)
	{
		Write-Verbose "Importing functions from file '$($_.Name)' by dotsourcing `"$($_.Fullname)`""
		. $_.Fullname
	}
	else
	{
		Write-Verbose "Ignoring file '$($_.Name)'"
	}
}
