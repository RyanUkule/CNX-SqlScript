-- use CNX
GO
insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 6, REPLACE(Name, 'HLT', 'LEO') as Name, Currency from RequestType_lkp where Name like '%HLT%'

