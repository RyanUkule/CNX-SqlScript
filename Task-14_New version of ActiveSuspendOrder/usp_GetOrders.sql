USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetOrders]    Script Date: 2017/08/18 14:40:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************
Author: Ryan.Han
Create Date: 2017-08-18
***********************************/
CREATE PROCEDURE [dbo].[usp_GetOrders]
(
	@OrderId INT
)
AS
BEGIN
	SELECT 
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
	  ,IsTakeOrder
	FROM OrderBook
	WHERE OrderId = @OrderId OR OriginalOrderId = @OrderId
END