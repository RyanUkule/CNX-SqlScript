USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_BatchUpdateExchangeSetting]    Script Date: 2018/01/03 10:43:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:		Percy  
-- Email:       peng.xingxing@itr.cn  
-- Create date:   
-- Modify date: 2016-10-25 12:01:30
-- Description: Batch Update Exchange Setting  
-- =============================================  
ALTER PROCEDURE [dbo].[usp_BatchUpdateExchangeSetting]  
@exchangeSettingId INT
,@orderBookOffset DECIMAL(18,8)
,@orderOffset DECIMAL(18,8)
,@buyRatio DECIMAL(18,8)
,@mapSellOrders BIT
,@mapBuyOrders BIT
,@frozen DECIMAL(18,8)
,@fundsTuUse DECIMAL(18,8)
,@priority DECIMAL(18,8)
,@status DECIMAL(18,8)
,@sellRatio DECIMAL(18,8)
,@buyMargin BIT
,@sellMargin BIT
,@buyConvertRate DECIMAL(18,8)
,@sellConvertRate DECIMAL(18,8)
,@minOnTradeVolume int
,@maxOnTradeVolume int
AS  
BEGIN 
  UPDATE ExchangeSetting 
  SET MapOrderOffset=@orderBookOffset
	  ,PlaceOrderOffset=@orderOffset
	  ,BuyRatio=@buyRatio
	  ,SellOrderMapping=@mapSellOrders
	  ,BuyOrderMapping=@mapBuyOrders
	  ,AllowFrozenRate=@frozen
	  ,AllowImportRate=@fundsTuUse
	  ,RankLevel=@priority
	  ,Active=@status
	  ,SellRatio=@sellRatio
	  ,UpdateDate=GETDATE()
	  ,BuyMargin = @buyMargin
	  ,SellMargin = @sellMargin
	  ,BuyConvertRate = @buyConvertRate
	  ,SellConvertRate = @sellConvertRate
	  ,MinOnTradeVolume = @minOnTradeVolume
	  ,MaxOnTradeVolume = @maxOnTradeVolume
  WHERE ExchangeSettingId=@exchangeSettingId
END
