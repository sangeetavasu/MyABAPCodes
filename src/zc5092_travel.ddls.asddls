@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for Travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC5092_TRAVEL  provider contract transactional_query
 as projection on ZR5092_TRAVEL
 {
 
@ObjectModel.text.element: [ 'AgencyName' ] 
    key AgencyId,
@Search.defaultSearchElement: true    
    key TravelId,
@Search.defaultSearchElement: true
@Search.fuzzinessThreshold: 0.8
    Description,
@Consumption.valueHelpDefinition: [{  entity.name: '/DMO/I_Customer_StdVH', entity.element: 'CustomerID' }]
@ObjectModel.text.element: [ 'CustomerName' ]
    CustomerId,
    BeginDate,
    EndDate,
    Status,
    ChangedAt,
    ChangedBy,
    CustomerName,
    _Agency.name as AgencyName  
 
}
