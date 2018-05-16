insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 6, REPLACE(Name, 'TNB', 'OMG') as Name, Currency from RequestType_lkp where Name like '%TNB%'

insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 8, REPLACE(Name, 'TNB', 'RCN') as Name, Currency from RequestType_lkp where Name like '%TNB%'

insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 10, REPLACE(Name, 'TNB', 'XRP') as Name, Currency from RequestType_lkp where Name like '%TNB%'

insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 12, REPLACE(Name, 'TNB', 'EOS') as Name, Currency from RequestType_lkp where Name like '%TNB%'

insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 14, REPLACE(Name, 'TNB', 'SPK') as Name, Currency from RequestType_lkp where Name like '%TNB%'

insert into RequestType_lkp (RequestTypeId, Name, Currency)
select RequestTypeId + 16, REPLACE(Name, 'TNB', 'WAX') as Name, Currency from RequestType_lkp where Name like '%TNB%'