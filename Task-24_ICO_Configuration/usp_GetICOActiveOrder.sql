USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetICOActiveOrder]    Script Date: 2017/11/23 18:06:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================= 
-- Author:  PengXingXing   
-- Email:   peng.xingxing@itr.cn        
-- Create date: 2017-8-15 15:47:31    
-- Modify date: 2017-8-15 15:47:31
-- Description: usp_GetICOActiveOrder
-- ============================================= 
ALTER PROCEDURE [dbo].[usp_GetICOActiveOrder]
@tokenId int
AS
BEGIN
	select 
	   [OrderId]
      ,[CustomerId]
      ,[OrderTypeId]
      ,[OfferAssetTypeId]
      ,[WantAssetTypeId]
      ,[Quantity]
      ,[Price]
      ,[OrderStatusId]
      ,[OriginalOrderId]
      ,[MarketOrder]
      ,[ExpirationDate]
      ,[TakeProfitOrderId]
      ,[StopLossOrderId]
      ,[UpdateDate]
      ,[InsertDate]
      ,[SaveDate]
      ,[RemoteExchangeId]
      ,[RemoteExchangeOrderNumber]
      ,[ParentOrderId]
      ,[OrderClassId]
      ,[IsTakeOrder]
	from OrderBook with (nolock) 
	where 
	OrderId in (select OrderId from CoinTokenOrderMapping with (nolock) where TokenId = @tokenId)
	and OrderStatusId = 2
END