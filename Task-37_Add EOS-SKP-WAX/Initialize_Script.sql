use CNX
--Add AssetType_lkp
	 INSERT INTO AssetType_lkp values('EOS', '', 1, '{CacheName:''EOSActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:0.02,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
	 INSERT INTO AssetType_lkp values('SPK', '', 0, '{CacheName:''SPKActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:6.0,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
	 INSERT INTO AssetType_lkp values('WAX', '', 1, '{CacheName:''WAXActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:76.0,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)

--Add balance for Users
exec usp_AddAssetBalanceForCustomer 26
exec usp_AddAssetBalanceForCustomer 27
exec usp_AddAssetBalanceForCustomer 28

--****** 1. EOS *****
	--Add ExchangeSetting
	--DRG_EOS
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 26
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_EOS'
			ELSE 'BFX_EOS'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_EOS', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_EOS
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 1, 26
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_EOS'
			ELSE 'BFX_USDT_EOS'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_EOS', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_EOS
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 5, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_EOS'
			ELSE 'BFX_BTC_EOS'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_EOS', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)

--****** 2. SPK *****
	--Add ExchangeSetting
	--DRG_SPK
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 4, 27
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_SPK'
			ELSE 'BFX_SPK'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 0, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_SPK', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_SPK
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 27
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_SPK'
			ELSE 'BFX_USDT_SPK'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 0, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_SPK', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_SPK
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_SPK'
			ELSE 'BFX_BTC_SPK'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 0, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_SPK', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
--****** 3. WAX *****
	--Add ExchangeSetting
	--DRG_WAX
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 4, 28
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_WAX'
			ELSE 'BFX_WAX'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_WAX', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_WAX
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 28
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_WAX'
			ELSE 'BFX_USDT_WAX'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_WAX', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_WAX
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_WAX'
			ELSE 'BFX_BTC_WAX'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_WAX', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
	
--Update Configuration
 
update Configuration set Value = Value + ',' + 'DRG_OMG,USDT_OMG,BTC_OMG,DRG_RCN,USDT_RCN,BTC_RCN,DRG_XRP,USDT_XRP,BTC_XRP,DRG_EOS,USDT_EOS,BTC_EOS,DRG_WAX,USDT_WAX,BTC_WAX'
where SettingId = 1051	
