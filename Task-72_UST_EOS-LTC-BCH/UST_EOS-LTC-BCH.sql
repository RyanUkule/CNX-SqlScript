--UST_EOS	
	INSERT INTO ExchangeSetting (ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage, CommissionAssetTypeId, PlatformId)
	SELECT 
		18 as ExchangeId
		, digits, AssetTypeId
		, 'UST_EOS' AS SettingName
		, SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 0, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_EOS', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, QuantityPercentage, 15, PlatformId
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_EOS' and ExchangeId = 18
	
--UST_LTC
	INSERT INTO ExchangeSetting (ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage, CommissionAssetTypeId, PlatformId)
	SELECT 
		18 as ExchangeId
		, digits, AssetTypeId
		, 'UST_LTC' AS SettingName
		, SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 0, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_LTC', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, QuantityPercentage, 15, PlatformId
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_LTC' and ExchangeId = 18
	
--UST_BCH
	INSERT INTO ExchangeSetting (ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage, CommissionAssetTypeId, PlatformId)
	SELECT 
		18 as ExchangeId
		, digits, AssetTypeId
		, 'UST_BCH' AS SettingName
		, SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 0, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_BCH', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, QuantityPercentage, 15, PlatformId
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_BCH' and ExchangeId = 18