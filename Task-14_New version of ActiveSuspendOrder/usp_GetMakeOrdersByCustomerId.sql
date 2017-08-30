USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMakeOrdersByCustomerId]    Script Date: 2017/08/25 16:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************
Author: Ryan.Han
Create Date: 2017-08-25
******************************/
CREATE PROCEDURE [dbo].[usp_GetMakeOrdersByCustomerId]
(
	@CustomerId INT,
	@OfferAssetTypeId INT
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
	WHERE CustomerId = @CustomerId AND OrderStatusId = 2 AND IsTakeOrder = 0 AND OfferAssetTypeId = @OfferAssetTypeId
	ORDER BY InsertDate
END
