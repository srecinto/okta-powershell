cls
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
$headers.Add("Authorization", $authorization)

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
                    algorithm = "SHA-256"
                    salt = "1qwdwe32"
                    saltOrder = "PREFIX"
                    value = $line.hashedPassword
                }
            }                        
        }
    } | ConvertTo-Json -Depth 10
    # Write-Output $user
    $result = Invoke-RestMethod -Uri $url -Headers $headers -Method "POST" -Body $user -ContentType "application/json" | ConvertTo-Json -Depth 10

}

Write-Output "created $($csvData.Length) users"
Write-Output "Create User - Completed"