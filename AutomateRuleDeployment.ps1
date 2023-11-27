$schema = '$schema'
$closeInformationalIncidentsAutomationRuleArmTemplate = @"
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

$gptApiConnectionArmTemplate = @"
{
    `"$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",
    `"contentVersion`": `"1.0.0.0`",
    `"parameters`": {
        `"connectionDisplayName`": {
            `"type`": `"String`",
            `"metadata`": {
                `"description`": `"The name of the ChatGPT (OpenAI) API connection.`"
            }
        },
        `"location`": {
            `"type`": `"String`",
            `"metadata`": {
                `"description`": `"The location where the API connection will be deployed.`"
            }
        },
        `"subscriptionId`": {
            `"type`": `"String`",
            `"metadata`": {
                `"description`": `"The subscription ID where the API connection will be deployed.`"
            }
        }
    },
    `"variables`": {},
    `"resources`": [
        {
            `"type`": `"Microsoft.Web/connections`",
            `"apiVersion`": `"2016-06-01`",
            `"name`": `"openaiip`",
            `"location`": `"[parameters('location')]`",
            `"kind`": `"V1`",
            `"properties`": {
                `"displayName`": `"[parameters('connectionDisplayName')]`",
                `"statuses`": [
                    {
                        `"status`": `"Connected`"
                    }
                ],
                `"customParameterValues`": {},
                `"nonSecretParameterValues`": {},
                `"api`": {
                    `"name`": `"openaiip`",
                    `"displayName`": `"[parameters('connectionDisplayName')]`",
                    `"description`": `"Connect to the OpenAI API and use the Power of GPT3, API key must be entered as \`"Bearer YOUR_API_KEY\`"`",
                    `"iconUri`": `"https://connectoricons-prod.azureedge.net/releases/v1.0.1637/1.0.1637.3300/openaiip/icon.png`",
                    `"brandColor`": `"#da3b01`",
                    `"id`": `"[concat('subscriptions/', parameters('subscriptionId'), '/providers/Microsoft.Web/locations/', parameters('location'), '/managedApis/openaiip')]`",
                    `"type`": `"Microsoft.Web/locations/managedApis`"
                },
                `"testLinks`": []
            }
        }
    ]
}
"@

$sentinelApiConnectionArmTemplate = @"
{
    `"$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",
    `"contentVersion`": `"1.0.0.0`",
    `"parameters`": {
        `"connectionDisplayName`": {
            `"type`": `"String`",
            `"metadata`": {
                `"description`": `"The name of the Azure Sentinel connection.`"
            }
        },
        `"location`": {
            `"type`": `"String`",
            `"defaultValue`": `"uksouth`",
            `"metadata`": {
                `"description`": `"The location where the API connection will be deployed.`"
            }
        },
        `"tenantId`": {
            `"type`": `"String`",
            `"metadata`": {
                `"description`": `"Tenant ID for the Azure Sentinel API connection.`"
            }
        },
        `"subscriptionId`": {
            `"type`": `"String`",
            `"metadata`": {
                `"description`": `"Subscription ID where the API connection will be deployed.`"
            }
        }
    },
    `"variables`": {},
    `"resources`": [
        {
            `"type`": `"Microsoft.Web/connections`",
            `"apiVersion`": `"2016-06-01`",
            `"name`": `"azuresentinel`",
            `"location`": `"[parameters('location')]`",
            `"kind`": `"V1`",
            `"properties`": {
                `"displayName`": `"[parameters('connectionDisplayName')]`",
                `"statuses`": [
                    {
                        `"status`": `"Connected`"
                    }
                ],
                `"customParameterValues`": {},
                `"nonSecretParameterValues`": {
                    `"token:TenantId`": `"[parameters('tenantId')]`",
                    `"token:grantType`": `"code`"
                },
                `"api`": {
                    `"name`": `"azuresentinel`",
                    `"displayName`": `"[parameters('connectionDisplayName')]`",
                    `"description`": `"Cloud-native SIEM with a built-in AI so you can focus on what matters most`",
                    `"iconUri`": `"[concat('https://connectoricons-prod.azureedge.net/releases/v1.0.1664/1.0.1664.3477/', 'azuresentinel', '/icon.png')]`",
                    `"brandColor`": `"#0072C6`",
                    `"id`": `"[concat('subscriptions/', parameters('subscriptionId'), '/providers/Microsoft.Web/locations/', parameters('location'), '/managedApis/', 'azuresentinel')]`",
                    `"type`": `"Microsoft.Web/locations/managedApis`"
                },
                `"testLinks`": []
            }
        }
    ]
}
"@
$connections = '$connections'
$gptAutoTaskLogicApp = @"
{
    `"$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",
    `"contentVersion`": `"1.0.0.0`",
    `"parameters`": {
        `"subscriptionId`": {
            `"type`": `"string`",
            `"metadata`": {
                `"description`": `"Subscription ID for deploying the Logic App.`"
            }
        },
        `"resourceGroupName`": {
            `"type`": `"string`",
            `"metadata`": {
                `"description`": `"Resource Group for deploying the Logic App.`"
            }
        },
        `"logicAppName`": {
            `"type`": `"string`",
            `"metadata`": {
                `"description`": `"Name of the Logic App.`"
            }
        },
        `"location`": {
            `"type`": `"string`",
            `"defaultValue`": `"uksouth`",
            `"metadata`": {
                `"description`": `"Location for deploying the Logic App.`"
            }
        }
    },
    `"variables`": {
        `"azuresentinelConnectionId`": `"[concat('/subscriptions/', parameters('subscriptionId'), '/resourceGroups/', parameters('resourceGroupName'), '/providers/Microsoft.Web/connections/azuresentinel')]`",
        `"openaiipConnectionId`": `"[concat('/subscriptions/', parameters('subscriptionId'), '/resourceGroups/', parameters('resourceGroupName'), '/providers/Microsoft.Web/connections/openaiip')]`"
    },
    `"resources`": [
        {
            `"type`": `"Microsoft.Logic/workflows`",
            `"apiVersion`": `"2019-05-01`",
            `"name`": `"[parameters('logicAppName')]`",
            `"location`": `"[parameters('location')]`",
            `"properties`": {
                `"definition`": {
                    `"$schema`": `"https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#`",
                    `"actions`": {
                        `"For_each`": {
                            `"actions`": {
                                `"Add_task_to_incident`": {
                                    `"inputs`": {
                                        `"body`": {
                                            `"incidentArmId`": `"@triggerBody()?['object']?['id']`",
                                            `"taskDescription`": `"<p>@{items('For_each')?['text']}</p>`",
                                            `"taskTitle`": `"Incident Triage`"
                                        },
                                        `"host`": {
                                            `"connection`": {
                                                `"name`": `"@parameters('$connections')['azuresentinel_1']['connectionId']`"
                                            }
                                        },
                                        `"method`": `"post`",
                                        `"path`": `"/Incidents/CreateTask`"
                                    },
                                    `"runAfter`": {},
                                    `"type`": `"ApiConnection`"
                                }
                            },
                            `"foreach`": `"@body('GPT3_Completes_your_prompt')?['choices']`",
                            `"runAfter`": {
                                `"GPT3_Completes_your_prompt`": [
                                    `"Succeeded`"
                                ]
                            },
                            `"type`": `"Foreach`"
                        },
                        `"For_each_2`": {
                            `"actions`": {
                                `"Add_task_to_incident_2`": {
                                    `"inputs`": {
                                        `"body`": {
                                            `"incidentArmId`": `"@triggerBody()?['object']?['id']`",
                                            `"taskDescription`": `"<p>@{items('For_each_2')?['text']}</p>`",
                                            `"taskTitle`": `"Contain, Mitigate & Recovery Steps`"
                                        },
                                        `"host`": {
                                            `"connection`": {
                                                `"name`": `"@parameters('$connections')['azuresentinel_1']['connectionId']`"
                                            }
                                        },
                                        `"method`": `"post`",
                                        `"path`": `"/Incidents/CreateTask`"
                                    },
                                    `"runAfter`": {},
                                    `"type`": `"ApiConnection`"
                                }
                            },
                            `"foreach`": `"@body('GPT3_Completes_your_prompt_2')?['choices']`",
                            `"runAfter`": {
                                `"GPT3_Completes_your_prompt_2`": [
                                    `"Succeeded`"
                                ]
                            },
                            `"type`": `"Foreach`"
                        },
                        `"GPT3_Completes_your_prompt`": {
                            `"inputs`": {
                                `"body`": {
                                    `"best_of`": 1,
                                    `"frequency_penalty`": 0,
                                    `"max_tokens`": 1000,
                                    `"model`": `"text-davinci-002`",
                                    `"n`": 1,
                                    `"presence_penalty`": 0,
                                    `"prompt`": `"You are a security engineer. Can you describe the steps to investigate and decide if a Cyber Security incident is a true positive or a false positive? Please write the following steps for the following incident:\\nTitle:\\n@{triggerBody()?['object']?['properties']?['title']}\\nDescription:\\n@{triggerBody()?['object']?['properties']?['description']}\\nSeverity:\\n@{triggerBody()?['object']?['properties']?['severity']}\\nEntities:\\n@{triggerBody()?['object']?['properties']?['relatedEntities']}\\nMITRE Tactics:\\n@{triggerBody()?['object']?['properties']?['additionalData']?['tactics']}\\nMITRE Techniques:\\n@{triggerBody()?['object']?['properties']?['additionalData']?['techniques']}\\nWe are using Sentinel as the SIEM. If there are any KQL queries that can help with this, please write them out as a KQL query and give an explanation for what the query is doing. It is important you use escape strings in the output as the text is being used in a JSON document. Please limit to 500 Characters `",
                                    `"temperature`": 1
                                },
                                `"host`": {
                                    `"connection`": {
                                        `"name`": `"@parameters('$connections')['openaiip_2']['connectionId']`"
                                    }
                                },
                                `"method`": `"post`",
                                `"path`": `"/v1/completions`"
                            },
                            `"runAfter`": {},
                            `"type`": `"ApiConnection`"
                        },
                        `"GPT3_Completes_your_prompt_2`": {
                            `"inputs`": {
                                `"body`": {
                                    `"best_of`": 1,
                                    `"frequency_penalty`": 0,
                                    `"max_tokens`": 100,
                                    `"model`": `"text-davinci-002`",
                                    `"n`": 1,
                                    `"presence_penalty`": 0,
                                    `"prompt`": `"You are a security engineer. Can you describe the steps to contain mitigate , and recover froma Security incident. Please write the following steps for the incident:\nTitle:\n@{triggerBody()?['object']?['properties']?['title']}\nDescription:\n@{triggerBody()?['object']?['properties']?['description']}\nSeverity:\n@{triggerBody()?['object']?['properties']?['severity']}Entities:\n@{triggerBody()?['object']?['properties']?['relatedEntities']}\nMITRE Tactics:\n@{triggerBody()?['object']?['properties']?['additionalData']?['tactics']}\nMITRE Techniques:\n@{triggerBody()?['object']?['properties']?['additionalData']?['techniques']}\nWe are using Sentinel as the SIEM. If there are any KQL queries that can help with this, please write them out as a KQL query and give an explanation for what the query is doing. It is important you use escape strings in the output as the text is being used in a JSON document. Please limit to 500 Characters`",
                                    `"temperature`": 1
                                },
                                `"host`": {
                                    `"connection`": {
                                        `"name`": `"@parameters('$connections')['openaiip_2']['connectionId']`"
                                    }
                                },
                                `"method`": `"post`",
                                `"path`": `"/v1/completions`"
                            },
                            `"runAfter`": {
                                `"For_each`": [
                                    `"Succeeded`"
                                ]
                            },
                            `"type`": `"ApiConnection`"
                        }
                    },
                    `"triggers`": {
                        `"Microsoft_Sentinel_incident`": {
                            `"inputs`": {
                                `"body`": {
                                    `"callback_url`": `"@{listCallbackUrl()}`"
                                },
                                `"host`": {
                                    `"connection`": {
                                        `"name`": `"@parameters('$connections')['azuresentinel_1']['connectionId']`"
                                    }
                                },
                                `"path`": `"/incident-creation`"
                            },
                            `"type`": `"ApiConnectionWebhook`"
                        }
                    },
                    `"contentVersion`": `"1.0.0.0`",
                    `"outputs`": {},
                    `"parameters`": {
                        `"$connections`": {
                            `"defaultValue`": {},
                            `"type`": `"Object`"
                        }
                    }
                },
                `"parameters`": {
                    `"$connections`": {
                        `"value`": {
                            `"azuresentinel_1`": {
                                `"connectionId`": `"[variables('azuresentinelConnectionId')]`",
                                `"connectionName`": `"azuresentinel`",
                                `"id`": `"[concat('/subscriptions/', parameters('subscriptionId'), '/providers/Microsoft.Web/locations/', parameters('location'), '/managedApis/azuresentinel')]`"
                            },
                            `"openaiip_2`": {
                                `"connectionId`": `"[variables('openaiipConnectionId')]`",
                                `"connectionName`": `"openaiip`",
                                `"id`": `"[concat('/subscriptions/', parameters('subscriptionId'),'/providers/Microsoft.Web/locations/', parameters('location'), '/managedApis/openaiip')]`"
                            }
                        }
                    }
                }
            }
        }
    ],
    `"outputs`": {}
}
"@

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
$apiName           = "MSSP-" + $customerName + "-API"
$logicAppName      = "MSSP-" + $customerName + "-LogicApp"
$customerTag       = "MSSP-" + $customerName + "-Tag"


try {
    # Set Azure subscription context
    az account set --subscription $subscriptionId
    Set-AzContext -SubscriptionId $subscriptionId
    Write-Host "Azure context set to subscription: $subscriptionId"
    # Get Tenant ID of the contexted subscription (Required for API connections)
    $tenantId = (Get-AzContext).Tenant.Id
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


$sentinelApiConnectionTemplate = "SentinelAPIConnectionARMTemplate.json"
    $sentinelApiConnectionArmTemplate | Out-File -FilePath $sentinelApiConnectionTemplate

    # Deploy the ARM Template
    Write-Host "Deploying Sentinel API for Logic-Apps..."
    try {
        $apiNameSentinel = $apiName + "-Sentinel"
        $deploymentOutput = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                                        -TemplateFile $sentinelApiConnectionTemplate `
                                                        -connectionDisplayName $apiNameSentinel `
                                                        -location $location `
                                                        -tenantId $tenantId `
                                                        -subscriptionId $subscriptionId
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
    Remove-Item -Path $sentinelApiConnectionTemplate -Force
}


$gptApiConnectionTemplate = "AutomationRule-CloseInformaitonalIncidents-ARMTemplate.json"
    $gptApiConnectionArmTemplate | Out-File -FilePath $gptApiConnectionTemplate

    # Deploy the ARM Template
    Write-Host "Deploying GPT API for Logic-Apps..."
    try{
        $apiNameGpt = $apiName + "-GPT"
        $deploymentOutput = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                                        -TemplateFile $gptApiConnectionTemplate `
                                                        -connectionDisplayName $apiNameGpt `
                                                        -location $location `
                                                        -subscriptionId $subscriptionId
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
    Remove-Item -Path $gptApiConnectionTemplate -Force
}





$gptAutoTaskTemplate = "LogicApp-AutoTasks-ARMTemplate.json"
    $gptAutoTaskLogicApp | Out-File -FilePath $gptAutoTaskTemplate

    # Deploy the ARM Template
    Write-Host "Deploying GPT AutoTask Logic-App..."
    try{
        $logicAppNameGpt = $logicAppName + "-AutomateTaskPopulation"
        $deploymentOutput = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                                        -TemplateFile $gptAutoTaskTemplate `
                                                        -logicAppName $logicAppNameGpt `
                                                        -location $location `
                                                        -subscriptionId $subscriptionId
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
    Remove-Item -Path $gptAutoTaskTemplate -Force
}



$closeInformaitonalIncidentsTemplate = "AutomationRule-CloseInformaitonalIncidents.json"
    $closeInformationalIncidentsAutomationRuleArmTemplate | Out-File -FilePath $closeInformaitonalIncidentsTemplate

    # Deploy the ARM Template
    Write-Host "Deploying Automation Rule: 'MSSP - Close All Informational Incidents'..."
    try {
        $deploymentParameters = @{
            "workspaceName" = $sentinelName
            "location" = $location
        }
        $deploymentOutput = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                                        -TemplateFile $closeInformaitonalIncidentsTemplate `
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
    Remove-Item -Path $closeInformaitonalIncidentsTemplate -Force
}



