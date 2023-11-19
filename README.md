# DevSecOps

This repo has been setup to share all things Development Security Operations related.

Manually create a subscription (to the best of my knowledge, no way to automate creation of subscriptions)
- Set the Customer Subscription - MSSP-<CustomerName>-Subscription
- Set the Subscription Tag - MSSP-<CusotmerName>-Tag : MSSP-<CustomerName>-Subscription

Run AutomateMSSPDeployment.ps1:
-  Supply the Subscription ID
-  Supply the CustomerName
-  Supply the Location to host the resources

Run AutomateRuleDeployment.ps1:
- Variables should be picked up automatically if done under the same file directory.
- This will deploy automation rules, playbooks, workbooks and connect them together.

Manually enable workspace manager on the deployment:
- go to sentinel
- select relevant workspace
- go to settings
- from the settings blade, go to the 'settings' tab at the top (should be second option in)
- scroll untill you find 'Workspace Manager' and enable
