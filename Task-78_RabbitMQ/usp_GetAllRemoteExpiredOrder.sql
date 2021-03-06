USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAllRemoteExiperidtOrder]    Script Date: 2019/09/12 11:24:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_GetAllRemoteExiperidtOrder] 
as 
begin
   select [OrderId]
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
	  FROM [cnx].[dbo].[OrderBook]
	  where  ExpirationDate is not null and ExpirationDate<GETDATE()
	 and [OrderStatusId] NOT IN (4, 5, 11, 16)
end