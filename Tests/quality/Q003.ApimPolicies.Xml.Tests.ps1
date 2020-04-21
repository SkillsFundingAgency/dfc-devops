Describe "APIM Policies XML quality tests" -Tag "Quality" {

    $XMLfiles = Get-ChildItem -Path $PSScriptRoot\..\..\ApimPolicies\*.xml -File -Recurse

    foreach ($xmlfile in $XMLfiles) {
        $xml = New-Object System.Xml.XmlDocument

        Context $xmlfile.BaseName {

            It "XML loads" {
                { $xml.Load($xmlfile.FullName) }  | Should not Throw
            }

        }
    }
}
