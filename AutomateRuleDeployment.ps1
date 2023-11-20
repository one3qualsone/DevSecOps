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
$schema = '$schema'
$closeIncidentsAutomationRule = @"
{
    `"$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",
    `"contentVersion`": `"1.0.0.0`",
    `"resources`": [
      {
        `"type`": `"Microsoft.OperationalInsights/workspaces/providers/automationRules`",
        `"apiVersion`": `"2023-02-01`",
        `"name`": `"[concat(parameters('workspaceName'), '/Microsoft.SecurityInsights/', parameters('automationRuleName'))]`",
        `"location`": `"[parameters('location')]`",
        `"properties`": {
          `"displayName`": `"MSSP - Close All Informational Incidents`",
          `"order`": 996,
          `"triggeringLogic`": {
            `"isEnabled`": true,
            `"triggersOn`": `"Incidents`",
            `"triggersWhen`": `"Created`",
            `"conditions`": [
              {
                `"conditionType`": `"Property`",
                `"conditionProperties`": {
                  `"propertyName`": `"IncidentSeverity`",
                  `"operator`": `"Equals`",
                  `"propertyValues`": [
                    `"Informational`"
                  ]
                }
              }
            ]
          },
          `"actions`": [
            {
              `"order`": 1,
              `"actionType`": `"ModifyProperties`",
              `"actionConfiguration`": {
                `"severity`": null,
                `"status`": `"Closed`",
                `"classification`": `"BenignPositive`",
                `"classificationReason`": `"SuspiciousButExpected`",
                `"classificationComment`": `"Informational Security Incidents are used for dashboards and reporting purposes.`",
                `"owner`": null,
                `"labels`": null
              }
            }
          ]
        }
      }
    ],
    `"parameters`": {
      `"workspaceName`": {
        `"type`": `"string`",
        `"metadata`": {
          `"description`": `"Name of the Azure Sentinel workspace`"
        }
      },
      `"automationRuleName`": {
        `"type`": `"string`",
        `"defaultValue`": `"MSSP - Close All Informational Incidents`",
        `"metadata`": {
          `"description`": `"Name for the automation rule`"
        }
      },
      `"location`": {
        `"type`": `"string`",
        `"metadata`": {
          `"description`": `"Location for all resources.`"
        }
      }
    }
  }
"@
$templateFile = "AutomationRule-CloseInformaitonalIncidents.json"
    $closeIncidentsAutomationRule | Out-File -FilePath $templateFile

    # Deploy the ARM Template
    Write-Host "Deploying Automation Rule: 'MSSP - Close All Informational Incidents'..."
    try {
        $deploymentParameters = @{
            "workspaceName" = $sentinelName
            "location" = $location
        }
        $deploymentOutput = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                                        -TemplateFile $templateFile `
                                                        -TemplateParameterObject $deploymentParameters

    # Analyze the deployment output
    if ($deploymentOutput.ProvisioningState -eq "Succeeded") {
        Write-Host "Deployment succeeded."
    } else {
        Write-Host "Deployment failed."
        Write-Host $deploymentOutput
    }
} catch {
    Write-Host "An error occurred during deployment: $_"
}
finally {
    # Clean up - remove the ARM Template file
    Remove-Item -Path $templateFile -Force
}



