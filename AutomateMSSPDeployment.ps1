# Set Error Action Preference
$ErrorActionPreference = "Stop"

# Set These Variables:
$subscriptionId = "SubscriptionID"
$customerName = "Customer" # Enter customer name
$location = "Location" # Enter Location (e.g UKSouth)
$sku = "pergb2018"
$resourceGroupName = "MSSP-" + $customerName + "-ResourceGroup-Sentinel" 
$workspaceName = "MSSP-" + $customerName + "Workspace-Sentinel"
$sentinelName = "MSSP-" + $customerName + "-Sentinel"

# Set the subscription context
az account set --subscription $subscriptionId

try {
    # Create resource group
    Write-Host "Creating resource group..."
    az group create --name $resourceGroupName --location $location

# Define the ARM Template
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
