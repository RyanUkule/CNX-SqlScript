-- use CNX
GO
insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 38, REPLACE(Name, 'TNB', 'PAX') as Name, Currency from RequestType_lkp where Name like '%TNB%'

