# Invoke-AddOrUpdateCompositeRegistrations.ps1

This script creates/updates path and region registrations in the Composite shell, based upon the contents of a json based configuration file

## Usage

```powershell
./Invoke-AddOrUpdateCompositeRegistrations.ps1 -PathApiUrl <URL to Path API> -RegionApiUrl <URL to Region API> -RegistrationFile <Path To Registration File>
```

An example invocation:

```powershell
.\Invoke-AddOrUpdateCompositeRegistrations.ps1 -PathApiUrl https://dfc-dev-compui-paths-fa.azurewebsites.net/api -RegionApiUrl https://dfc-dev-compui-regions-fa.azurewebsites.net/api -RegistrationFile C:\Repos\dfc-app-jobprofiles\Resources\PageRegistration\registration.json
```

## Configuration File examples

```json
[
    {
        "Path": "path1",
        "TopNavigationText": "Path 1",
        "TopNavigationOrder": 100,
        "Layout": 1,
        "OfflineHtml": "App unavailable",
        "SitemapUrl": "https://path1-app.azurewebsites.net/sitemap.xml",
        "RobotsUrl": "https://path1-app.azurewebsites.net/robots.txt",
        "Regions": [
            {
                "PageRegion": 1,
                "RegionEndpoint": "https://path1-app.azurewebsites.net/path1/{0}/htmlhead",
                "HealthCheckRequired": false
            }
        ]
    },
    {
        "Path": "path2",
        "TopNavigationText": "Path 2",
        "TopNavigationOrder": 200,
        "Layout": 1,
        "OfflineHtml": "App unavailable",
        "SitemapUrl": "https://path2-app.azurewebsites.net/sitemap.xml",
        "RobotsUrl": "https://path2-app.azurewebsites.net/robots.txt",
        "Regions": [
            {
                "PageRegion": 1,
                "RegionEndpoint": "https://path2-app.azurewebsites.net/path2/{0}/htmlhead",
                "HealthCheckRequired": false
            }
        ]
    }
]
```

The above configuration file registers two paths, Path1 and Path2.

Each of these paths has a single region within it.

Please note:
If a Path registration lacks an `IsOnline` property or Region registration lack an `IsHealthy` property,  it will be defaulted to true.
