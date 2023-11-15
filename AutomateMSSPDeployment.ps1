# Set Error Action Preference
$ErrorActionPreference = "Stop"

# Ask for user input
function Get-UserInput {
    $subscriptionId = Read-Host -Prompt "Enter your Azure Subscription ID"
    $customerName = Read-Host -Prompt "Enter the Customer Name"
    $location = Read-Host -Prompt "Enter the Azure Region (e.g., UKSouth)"

    $userInfo = @{
        SubscriptionId = $subscriptionId
        CustomerName = $customerName
        Location = $location
    }

    return $userInfo
}

# Confirm user input
function Confirm-UserInput($userInfo) {
    Write-Host "Here is your inputted information:"
    Write-Host "Subscription ID: $($userInfo.SubscriptionId)"
    Write-Host "Customer Name: $($userInfo.CustomerName)"
    Write-Host "Location: $($userInfo.Location)"

    $confirmation = Read-Host "Do you want to proceed? (Y/N)"
    return $confirmation -eq "Y" -or $confirmation -eq "y"
}

# Ask for confirmatrion
do {
    $userInfo = Get-UserInput

    $confirmation = Confirm-UserInput -userInfo $userInfo
    if (-not $confirmation) {
        Write-Host "Restarting the script..."
    }
} while (-not $confirmation)

# If confirmed, proceed with deployment
$subscriptionId = $userInfo.SubscriptionId
$customerName = $userInfo.CustomerName
$location = $userInfo.Location

# Function to check and register resource providers
function CheckAndRegisterResourceProviders {
    $requiredProviders = @("Microsoft.OperationsManagement", "Microsoft.SecurityInsights")

    foreach ($provider in $requiredProviders) {
        $state = (az provider show --namespace $provider --query "registrationState" -o tsv)
        if ($state -ne "Subscription is Registered. Continuing with resource deployment...") {
            Write-Host "Subscription is not Registered. Registering resource provider $provider. This may take a few minutes..."
            az provider register --namespace $provider
            # Wait for the registration to complete
            Start-Sleep -Seconds 30
        }
    }
}

CheckAndRegisterResourceProviders

$sku = "pergb2018"
$resourceGroupName = "MSSP-" + $customerName + "-ResourceGroup-Sentinel" 
$workspaceName = "MSSP-" + $customerName + "Workspace-Sentinel"
$sentinelName = "MSSP-" + $customerName + "-Sentinel"
# Set subscription context
az account set --subscription $subscriptionId

try {
    # Create resource group
    Write-Host "Creating resource group..."
    az group create --name $resourceGroupName --location $location

# Define Deployment ARM Template
$schema = '$schema'
$armTemplate = @"
{
  `"$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",
  `"contentVersion`": `"1.0.0.0`",
  `"parameters`": {
    `"name`": {
      `"type`": `"string`",
      `"metadata`": {
        `"description`": `"Name for your log analytics workspace`"
      }
    },
    `"location`": {
      `"type`": `"string`",
      `"metadata`": {
        `"description`": `"Azure Region to deploy the Log Analytics Workspace`"
      }
    },
    `"sku`": {
      `"type`": `"string`",
      `"metadata`": {
        `"description`": `"SKU, leave default pergb2018`"
      }
    }
  },
  `"resources`": [
    {
      `"type`": `"Microsoft.OperationalInsights/workspaces`",
      `"apiVersion`": `"2020-03-01-preview`",
      `"name`": `"[parameters('name')]`",
      `"location`": `"[parameters('location')]`",
      `"properties`": {
        `"sku`": {
          `"name`": `"[parameters('sku')]`"
        }
      }
    },
    {
      `"name`": `"[concat(parameters('name'),'/Microsoft.SecurityInsights/default')]`",
      `"type`": `"Microsoft.OperationalInsights/workspaces/providers/onboardingStates`",
      `"apiVersion`": `"2021-03-01-preview`",
      `"location`": `"[resourceGroup().location]`",
      `"dependsOn`": [
        `"[resourceId('Microsoft.OperationalInsights/workspaces/', parameters('name'))]`"
      ],
      `"properties`": {
      }
    }
  ]
}
"@
 # Save the ARM Template to a file
    $templateFile = "armTemplate.json"
    $armTemplate | Out-File -FilePath $templateFile

    # Deploy the ARM Template
    Write-Host "Deploying ARM template..."
    $deploymentOutput = az deployment group create `
                        --resource-group $resourceGroupName `
                        --template-file $templateFile `
                        --parameters name=$sentinelName location=$location sku=$sku

    # Analyze the deployment output
    if ($deploymentOutput -match "Succeeded") {
        Write-Host "Deployment succeeded."
    } else {
        Write-Host "Deployment failed."
        Write-Host $deploymentOutput
    }

    # Clean up - remove the ARM Template file
    Remove-Item $templateFile
}
catch {
    Write-Host "An error occurred: $_"
}
finally {
    Write-Host "Script execution completed."
}
