USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_loadAllActiveExchangeSettings]    Script Date: 2019/05/10 15:21:49 ******/
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
			  [ExchangeSetting].QuantityPercentage,
			  [ExchangeSetting].CommissionAssetTypeId,
			  [ExchangeSetting].PlatformId
		  FROM [cnx].[dbo].[ExchangeSetting] with (nolock)
		  left join Exchanges with(nolock) on ExchangeSetting.ExchangeId = Exchanges.ExchangeId
		  where [ExchangeSetting].Active = 1 and Exchanges.Active = 1 and PlatformId = 1
	END

	/****** Object:  StoredProcedure [dbo].[usp_loadAllExchangeSettings]    Script Date: 2016/10/11 16:40:56 ******/
	SET ANSI_NULLS ON

