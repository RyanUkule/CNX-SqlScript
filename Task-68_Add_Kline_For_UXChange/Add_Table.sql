--1.Platform
USE CNX
GO
	CREATE TABLE Platform_lkp
	(
		PlatformId int IDENTITY(1, 1) PRIMARY KEY,
		PlatformName nvarchar(50),
		Description nvarchar(max),
		Active bit
	)

GO
	INSERT INTO Platform_lkp(PlatformName, Description, Active) VALUES('CNX','C2CX', 1)
	INSERT INTO Platform_lkp(PlatformName, Description, Active) VALUES('UX','U.Exchange', 1)

GO
	ALTER TABLE ExchangeSetting
	Add PlatformId int not null default 1 foreign key references Platform_lkp(PlatformId)

--2.Exchanges
	SET IDENTITY_INSERT Exchanges ON

	INSERT INTO Exchanges(ExchangeId, ExchangeName, ExchangeAddress, APIKey, AccessKey, LimitCallPerSecond, LimitAPICallPerSecond, Active)
	VALUES(32, 'UX', null, '', '', null, null, 1)
	
	SET IDENTITY_INSERT Exchanges OFF
	
--3.Configuration
	INSERT INTO Configuration(Name, Value, Description, SortOrder, UpdateDate, InsertDate, SaveDate)
	VALUES('UXDomainList', 'u.exchange', 'UX website domain list', null, GETDATE(), GETDATE(), GETDATE() )
	
	INSERT INTO Configuration(Name, Value, Description, SortOrder, UpdateDate, InsertDate, SaveDate)
	VALUES('C2CXDomainList', 'c2cx', 'C2CX website domain list', null, GETDATE(), GETDATE(), GETDATE() )
	
--4.ExchangeSetting
	--USDT_BTC for UX
	-- INSERT INTO ExchangeSetting (ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			-- , AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			-- , BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage, CommissionAssetTypeId, PlatformId)
	-- SELECT 
		-- 32 as ExchangeId
		-- , digits, AssetTypeId
		-- , 'CNX_USDT_BTC' AS SettingName
		-- , SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		-- , BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_BTC', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		-- , QuantityPercentage, CommissionAssetTypeId, 2
	-- FROM ExchangeSetting
	-- WHERE Symbol = 'USDT_BTC' and exchangeId = 16

