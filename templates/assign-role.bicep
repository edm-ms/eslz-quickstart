param assignmentName string = '<>'
param principalId string    = '<>'
param time string           = utcNow()

var roles = json(loadTextContent('parameters/contributor-roles.json'))

 module assignRole 'modules/role-assign.bicep' = {
   name: 'roleAssign-${time}'
   params: {
     assignmentName: assignmentName
     principalType: 
     principalId:  principalId
     roleId: 
   }
 }
