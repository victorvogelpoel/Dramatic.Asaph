﻿# Assert-AsaphLoggedOn.psm1
# Assert that Connect-Asaph was used to log on before any other command is used.
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