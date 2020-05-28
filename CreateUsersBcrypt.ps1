 cls
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Output "Create User - Starting"

Write-Output "Loading Config"
$config=Get-Content -Path .\config.json -Raw | ConvertFrom-Json
Write-Output $config

Write-Output "Import CSV"
$csvData = Import-Csv -Path .\user.csv

$url = $config.okta_url + "/api/v1/users?activate=true"
$authorization = "SSWS " + $config.okta_api_token

$headers = @{}
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", $authorization)

# Write-Output $headers | ConvertTo-Json -Depth 10

Write-Output "Creating User(s)"
foreach ($line in $csvData) {
    $user = @{
        profile = @{
            firstName = $line.firstName
            lastName = $line.lastName
            login = $line.email
            email = $line.email
        }
        credentials = @{
            password = @{
                hash = @{
                    algorithm = "BCRYPT"
                    salt = 'YEQbZKcz2pY4j0.nKAUK2O'
                    workFactor = "6"
                    value = $line.hashedPassword
                }
            }                        
        }
    } | ConvertTo-Json -Depth 10
    # Write-Output $user
    # Write-Output $url
    # Write-Output $headers
    try {
        $result = Invoke-RestMethod -Uri $url -Headers $headers -Method "POST" -Body $user -ContentType "application/json" -ErrorVariable RespErr | ConvertTo-Json -Depth 10
        Write-Output $result
    } catch {
        $err=$_.Exception
        Write-Output "Error"
        Write-Output $err.Message
        Write-Output $err.Status
        # Write-Output $err.Response | ConvertTo-Json -Depth 10
    }
}

Write-Output "created $($csvData.Length) users"
Write-Output "Create User - Completed" 
