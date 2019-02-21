# Redis Cache

Creates a Redis cache.

## Paramaters

redisName: (required) string

Name of Redis cache. Will be created in the same resource group as the script is run and in the default location for resource group.

redisSkuName: (optional) string

Specifies the Redis SKU to use (see https://azure.microsoft.com/en-us/pricing/details/cache/ for details of what each provides).
Must be one of Basic, Standard or Premium.
Will default to Standard if not speficied.

redisCapacity: (optional) int

Redis cache capacity. Basic and standard can be between 0 and 6. Premium is between 0 and 5.
See see https://azure.microsoft.com/en-us/pricing/details/cache/ for details about the size 
