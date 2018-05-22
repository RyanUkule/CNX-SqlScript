use CNX
GO
insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 20, REPLACE(Name, 'TNB', 'XLM') as Name, Currency from RequestType_lkp where Name like '%TNB%'
