param appname string
param budgetAmount int
param start string = utcNow('yyyy-MM-dd')
param contactEmail string
param resourceGroup string

var dateSplit = split(start, '-')
var year = dateSplit[0]
var month = dateSplit[1]
var adjustedStart = '${year}-${month}-01'

resource budget 'Microsoft.Consumption/budgets@2019-10-01' = {
  name: appname
  properties: {
   timePeriod: {
     startDate: adjustedStart
   }
   category: 'Cost'
   amount: budgetAmount
   timeGrain: 'Monthly'
   notifications: {
    NotificationForExceededBudget1:{
     enabled: true
     operator: 'GreaterThan'
     threshold: 100
     contactEmails: [
       contactEmail
     ]
    }
   }
   filter: {
     and: [
       {
         dimensions: {
           name: 'ResourceGroupName'
           operator: 'In'
           values: [
             resourceGroup
           ]
         }
       }
     ]
   }

 }
  
}
