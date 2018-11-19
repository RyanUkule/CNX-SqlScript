
use CNX
--1. Add AssetType_lkp
	 SET identity_insert assetType_lkp ON
		 insert into assettype_lkp(AssetTypeId, Name, Symbol, IsActive, Info, NameBlurb, Block, ReferAssetTypeId, Circulation, AccountManagerId, FundAccountId)
		 values(42, 'BAB', '', 1, '{cachename:''BABActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:10,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', '22208',null, null, null, null, null)
		 
		 insert into assettype_lkp(AssetTypeId, Name, Symbol, IsActive, Info, NameBlurb, Block, ReferAssetTypeId, Circulation, AccountManagerId, FundAccountId)
		 values(43, 'BSV', '', 1, '{cachename:''BSVActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:10,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', '22209',null, null, null, null, null)
	 SET identity_insert assetType_lkp OFF
	 
	 exec usp_AddAssetBalanceForCustomer 42
	 exec usp_AddAssetBalanceForCustomer 43
	 
--2. Add ExchangeSetting
	--BAB
	--USDT_BAB
	INSERT INTO ExchangeSetting(ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage)
	SELECT 
		Case ExchangeId
		WHEN 16 THEN 16
		ELSE 18 ENd 
		AS ExchangeId
		, 0, 42
		,CASE ExchangeId 
		 WHEN 16 THEN 'CNX_USDT_BAB' 
		 ELSE 'BF_USDT_BAB' END
		 AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_BAB', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, 1
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--DRG_BAB
	INSERT INTO ExchangeSetting(ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage)
	SELECT 
		Case ExchangeId
		WHEN 16 THEN 16
		ELSE 18 ENd 
		AS ExchangeId
		, 1, 42
		,CASE ExchangeId 
		 WHEN 16 THEN 'CNX_DRG_BAB' 
		 ELSE 'BF_DRG_BAB' END
		 AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_BAB', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, 1
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--BTC_BAB
	INSERT INTO ExchangeSetting(ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage)
	SELECT 
		Case ExchangeId
		WHEN 16 THEN 16
		ELSE 18 ENd 
		AS ExchangeId
		, 4, 42
		,CASE ExchangeId 
		 WHEN 16 THEN 'CNX_BTC_BAB' 
		 ELSE 'BF_BTC_BAB' END
		 AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_BAB', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, 1
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
	--BSV
	INSERT INTO ExchangeSetting(ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage)
	SELECT 
		Case ExchangeId
		WHEN 16 THEN 16
		ELSE 18 ENd 
		AS ExchangeId
		, 1, 43
		,CASE ExchangeId 
		 WHEN 16 THEN 'CNX_USDT_BSV' 
		 ELSE 'BF_USDT_BSV' END
		 AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_BSV', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, 1
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--DRG_BSV
	INSERT INTO ExchangeSetting(ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage)
	SELECT 
		Case ExchangeId
		WHEN 16 THEN 16
		ELSE 18 ENd 
		AS ExchangeId
		, 2, 43
		,CASE ExchangeId 
		 WHEN 16 THEN 'CNX_DRG_BSV' 
		 ELSE 'BF_DRG_BSV' END
		 AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_BSV', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, 1
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--BTC_BSV
	INSERT INTO ExchangeSetting(ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage)
	SELECT 
		Case ExchangeId
		WHEN 16 THEN 16
		ELSE 18 ENd 
		AS ExchangeId
		, 5, 43
		,CASE ExchangeId 
		 WHEN 16 THEN 'CNX_BTC_BSV' 
		 ELSE 'BF_BTC_BSV' END
		 AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_BSV', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, 1
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	

--3. Configuration	
	--update Configuration set Value = Value + ',PAX' where SettingId = 1051	
	update Configuration set Value = '{USDT_Unit:''SKY,UCASH,SYN1,AGRS,PAX,BAB,BSV'', BTC_Only:''TRIA,BEZ,SLRM''}'  where name = 'LimitAmountSymbol'