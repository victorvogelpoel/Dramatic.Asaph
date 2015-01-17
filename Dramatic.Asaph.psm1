# Dramatic.Asaph.psm1
# Module for Phoboslab Asaph micro blogging system (http://phoboslab.org/projects/asaph)
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

# Define the PublishResult
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
	'install.ps1'
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
