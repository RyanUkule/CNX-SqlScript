
use CNX
--1. Add AssetType_lkp
	 SET identity_insert assetType_lkp ON
		 insert into assettype_lkp(AssetTypeId, Name, Symbol, IsActive, Info, NameBlurb, Block, ReferAssetTypeId, Circulation)
		 values(39, 'PAX', '', 1, '{cachename:''PAXActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:10,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', '22198',null, null, null)
	 SET identity_insert assetType_lkp OFF
	 
	 exec usp_AddAssetBalanceForCustomer 39
	 
--2. Add ExchangeSetting
	--USDT_PAX
	INSERT INTO ExchangeSetting(ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage)
	SELECT 
		Case ExchangeId
		WHEN 16 THEN 16
		ELSE 30 ENd 
		AS ExchangeId
		, 3, 39
		,CASE ExchangeId 
		 WHEN 16 THEN 'CNX_USDT_PAX' 
		 ELSE 'Binance_USDT_PAX' END
		 AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_PAX', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, 1
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in(16, 18)
	

--3. Configuration	
	update Configuration set Value = Value + ',PAX' where SettingId = 1051	
	update Configuration set Value = '{USDT_Unit:''SKY,UCASH,SYN1,AGRS,PAX'', BTC_Only:''TRIA,BEZ,SLRM''}'  where name = 'LimitAmountSymbol'