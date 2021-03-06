USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_loadAllExchangeSettings]    Script Date: 2018/01/03 17:15:04 ******/
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
   FROM [cnx].[dbo].[ExchangeSetting] with (nolock)  
   --where Active = 1  
END  