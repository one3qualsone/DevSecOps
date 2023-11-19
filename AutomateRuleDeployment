# Set Error Action Preference
$ErrorActionPreference = "Stop"

# Function to get user input if variables cant be imported
function Get-MissingVariables {
    param(
        [string]$subscriptionId,
        [string]$customerName,
        [string]$location
    )
    if (-not $subscriptionId) {
        $subscriptionId = Read-Host -Prompt "Enter your Azure Subscription ID"
    }
    if (-not $customerName) {
        $customerName = Read-Host -Prompt "Enter the Customer Name"
    }
    if (-not $location) {
        $location = Read-Host -Prompt "Enter the Azure Region (e.g., UKSouth)"
    }
    return @{
        SubscriptionId = $subscriptionId
        CustomerName   = $customerName
        Location       = $location
    }
}

# Attempt to import variables
try {
    $importedVariables = Get-Content -Path 'scriptVariables.json' -ErrorAction Stop | ConvertFrom-Json
}
catch {
    Write-Host "Unable to import variables. Will ask for user input."
    $importedVariables = @{}
}

# Check and get missing variables
$userInput = Get-MissingVariables -subscriptionId $importedVariables.SubscriptionId -customerName $importedVariables.CustomerName -location $importedVariables.Location

# Assign variables, using either imported or user-input values
$subscriptionId    = $userInput.SubscriptionId
$customerName      = $userInput.CustomerName
$location          = $userInput.Location
$sku               = "pergb2018"
$resourceGroupName = "MSSP-" + $customerName + "-ResourceGroup-Sentinel" 
$sentinelName      = "MSSP-" + $customerName + "-Sentinel"
$customerTag       = "MSSP-" + $customerName + "-Tag"

try {
    # Set Azure subscription context
    az account set --subscription $subscriptionId
    Set-AzContext -SubscriptionId $subscriptionId
    Write-Host "Azure context set to subscription: $subscriptionId"

    # Define tags
    $tag = "MSSP-" + $customerName + "-Tag"

    # Apply tags to the resource group
    Write-Host "Applying tags to the resource group..."
    az group update --name $resourceGroupName --tags "$tag=$resourceGroupName"

    # Apply tags to the Workspace
    Write-Host "Applying tags to the Workspace..."
    $workspaceId = az resource list --query "[?name=='$sentinelName'].id" -o tsv
    az resource tag --ids $workspaceId --tags "$tag=$sentinelName"
    Write-Host "Tags applied successfully."
}
catch {
    Write-Host "An error occurred while applying tags: $_"
}
finally {
    Write-Host "Tagging process completed."
}






