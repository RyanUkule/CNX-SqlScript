update AssetType_lkp set active = 1 where assetTypeId = 30
update ExchangeSetting set active = 1 where symbol like '%tria%'
update Configuration set Value = Value + ',' + 'BTC_TRIA' where SettingId = 1051
	