
BeforeDiscovery {
    $XMLfiles += (Get-ChildItem -Path $PSScriptRoot\..\..\ApimPolicies\*.xml -File -Recurse)
}
Describe "APIM Policies XML quality tests" -ForEach @($XMLfiles) -Tag "Quality" {
    Context "XML Test $($_.BaseName)"{
        It "XML loads $($_.FullName)" {
            $xml = New-Object System.Xml.XmlDocument
            { $xml.Load($_.FullName) } | Should -Not -Throw
        }
    }
}