use CNX
GO
insert into Configuration values('LimitAmountSymbol', '{USDT_Unit:''SKY,UCASH'', BTC_Only:''TRIA,BEZ,SLRM'',}', 'Special symbol for limit amount', null, GETDATE(), GETDATE(), GETDATE())
insert into Configuration values('LocalAssetType', 'SKY,UCASH,TRIA,BEZ,SLRM', 'Local asset type', null, GETDATE(), GETDATE(), GETDATE())