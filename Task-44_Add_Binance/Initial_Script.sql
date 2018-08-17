USE CNX
GO
-- 1. 修改RemoteBalance表 BalanceString 长度
	alter table remotebalance
	alter column BalanceString nvarchar(max)
GO
-- 2. Add Exchanges
	SET IDENTITY_INSERT exchanges ON

	INSERT INTO exchanges ([ExchangeId],[ExchangeName],[ExchangeAddress],[APIKey],[AccessKey],[LimitCallPerSecond],[LimitAPICallPerSecond],[Active])
	VALUES(30, 'Binance', 'https://api.binance.com/', '', '', null, null, 1)

	SET IDENTITY_INSERT exchanges OFF
GO
-- 3. Add ExchangeSetting
	INSERT INTO ExchangeSetting (ExchangeId, digits, AssetTypeId, SettingName, SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel,Active
		, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume)
	select  30, digits, AssetTypeId, 'Binance_USDT_BTC', SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, 2, 1
		, GETDATE(), BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	from ExchangeSetting where symbol = 'USDT_BTC' and ExchangeId = 18

-- -- 4. Add Configuration
	-- INSERT INTO Configuration(Name, Value, Description, SortOrder, UpdateDate, InsertDate, SaveDate)
	-- VALUES('NoNeedMappingsSymbols', 'BTC_SKY', 'The symbols that doesn\'t send make order to Api, such as Binance.', null, GETDATE(), GETDATE(), GETDATE())

-- 5. 修改AssetType_lkp
	update assetType_lkp set info ='{CacheName:'''',MOASPreferenceId:0,SLASPreferenceId:0,FloatMarketPrice:1,LimitAmount:10,Model:1,Focus:5,FocusPercentage:0.6, LimitPriceDigit:0,MinBlock:1,BlockRequest:0}'
	where name = 'SKY'
	
--6.
Go
	--BTC_SKY
	Alter table ExchangeSetting
	Add QuantityPercentage decimal(18, 4) default 1
GO
	Update ExchangeSetting set  QuantityPercentage = 1

	update ExchangeSetting set quantityPercentage  = 0.8 where exchangeId = 30 and symbol = 'BTC_SKY'
	---

	GO
	/****** Object:  StoredProcedure [dbo].[usp_loadAllActiveExchangeSettings]    Script Date: 2018/08/14 15:05:50 ******/
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	-- =============================================
	-- Author:		<Author,,Name>
	-- Create date: <Create Date,,>
	-- Description:	<Description,,>
	-- =============================================
	ALTER PROCEDURE [dbo].[usp_loadAllActiveExchangeSettings]

	AS
	BEGIN
		SELECT [ExchangeSetting].[ExchangeSettingId],
			  [ExchangeSetting].[ExchangeId],
			  [ExchangeSetting].[digits],
			  [ExchangeSetting].[AssetTypeId],
			  [ExchangeSetting].[SettingName],
			  [ExchangeSetting].[SellOrderMapping],
			  [ExchangeSetting].[BuyOrderMapping],
			  [ExchangeSetting].[MapOrderOffset],
			  [ExchangeSetting].[PlaceOrderOffset],
			  [ExchangeSetting].[AllowFrozenRate],
			  [ExchangeSetting].[AllowImportRate],
			  --[ExchangeSetting].[AllowMaxFrozenRate],
			  --[ExchangeSetting].[BuyParameter],
			  --[ExchangeSetting].[SellParameter],
			  --[ExchangeSetting].[RandMaxValue],
			  [ExchangeSetting].[BuyRatio],
			  [ExchangeSetting].[SellRatio],
			  [RankLevel],
			  [ExchangeSetting].[BuyMargin],
			  [ExchangeSetting].[SellMargin],
			  [ExchangeSetting].[Active],
			  [ExchangeSetting].[Symbol],
			  [ExchangeSetting].QuantityDigit,
			  [ExchangeSetting].BuyConvertRate,
			  [ExchangeSetting].SellConvertRate,
			  [ExchangeSetting].MinOnTradeVolume,
			  [ExchangeSetting].MaxOnTradeVolume,
			  [ExchangeSetting].QuantityPercentage
		  FROM [cnx].[dbo].[ExchangeSetting] with (nolock)
		  left join Exchanges with(nolock) on ExchangeSetting.ExchangeId = Exchanges.ExchangeId
		  where [ExchangeSetting].Active = 1 and Exchanges.Active = 1
	END

	/****** Object:  StoredProcedure [dbo].[usp_loadAllExchangeSettings]    Script Date: 2016/10/11 16:40:56 ******/
	SET ANSI_NULLS ON

	GO
	/****** Object:  StoredProcedure [dbo].[usp_loadAllExchangeSettings]    Script Date: 2018/08/14 15:21:01 ******/
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	-- =============================================  
	-- Author:  <Author,,Name>  
	-- Create date: <Create Date,,>  
	-- Modify date: 2016-10-26 12:09:56  
	-- Description: <Description,,>  
	-- =============================================  
	ALTER PROCEDURE [dbo].[usp_loadAllExchangeSettings]    
	AS  
	BEGIN  
	 SELECT [ExchangeSettingId]  
		,[ExchangeId]  
		,[Digits]  
		,[AssetTypeId]  
		,[SettingName]  
		,[SellOrderMapping]  
		,[BuyOrderMapping]  
		,[MapOrderOffset]  
		,[PlaceOrderOffset]  
		,[AllowFrozenRate]  
		,[AllowImportRate]  
		--,[AllowMaxFrozenRate]  
		--,[BuyParameter]  
		--,[SellParameter]  
		--,[RandMaxValue]  
		,[RankLevel]  
		,[BuyRatio]  
		,[SellRatio]  
		,[BuyMargin]
		,[SellMargin]
		,[Active]
		,[Symbol]
		,[UpdateDate]  
		,[QuantityDigit]
		,BuyConvertRate
		,SellConvertRate
		,MinOnTradeVolume
		,MaxOnTradeVolume
		,QuantityPercentage
	   FROM [cnx].[dbo].[ExchangeSetting] with (nolock)  
	   --where Active = 1  
	END  