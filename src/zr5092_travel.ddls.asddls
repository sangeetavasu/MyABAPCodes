
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Data definition for Travel'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR5092_TRAVEL as select from z5092_travel
association to /dmo/agency as _Agency on $projection.AgencyId = _Agency.agency_id
association to /dmo/customer as _Customer on $projection.CustomerId = _Customer.customer_id
{
    key agency_id as AgencyId,
    key travel_id as TravelId,
    description as Description,
    customer_id as CustomerId,
    begin_date as BeginDate,
    end_date as EndDate,
    status as Status,
    @Semantics.systemDateTime.lastChangedAt: true
    changed_at as ChangedAt,
    @Semantics.user.lastChangedBy: true
    changed_by as ChangedBy,
   concat_with_space( _Customer.first_name,_Customer.last_name, 1 ) as CustomerName,
    _Agency,
    _Customer
}
