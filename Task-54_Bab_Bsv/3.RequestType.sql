-- use CNX
GO
insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 40, REPLACE(Name, 'TNB', 'BAB') as Name, Currency from RequestType_lkp where Name like '%TNB%'

insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 42, REPLACE(Name, 'TNB', 'BSV') as Name, Currency from RequestType_lkp where Name like '%TNB%'
