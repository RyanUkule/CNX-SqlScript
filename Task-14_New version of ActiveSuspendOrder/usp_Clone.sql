USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_cloneOrder]    Script Date: 2017/08/16 16:24:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_cloneOrder] 
@orderId int,
@IsTaker bit
AS
BEGIN
	declare @NewOrderId int
	Insert into OrderBook (   
		   [CustomerId]
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
		  ,IsTakeOrder)
	SELECT 
		   [CustomerId]
		  ,[OrderTypeId]
		  ,[OfferAssetTypeId]
		  ,[WantAssetTypeId]
		  ,[Quantity]
		  ,[Price]
		  ,[OrderStatusId]
		  ,case when [OriginalOrderId] is null then @orderId else [OriginalOrderId] end
		  ,[MarketOrder]
		  ,[ExpirationDate]
		  ,[TakeProfitOrderId]
		  ,[StopLossOrderId]
		  ,getdate()
		  ,getdate()
		  ,getdate()
		  ,[RemoteExchangeId]
		  ,[RemoteExchangeOrderNumber]
		  ,[ParentOrderId]
		  ,[OrderClassId]
		  ,@IsTaker
	  FROM [cnx].[dbo].[OrderBook] 
	  where orderid = @orderId and OrderStatusId not in (4,5,16)

	  SET @NewOrderId = SCOPE_IDENTITY()  

	  if(@NewOrderId is not null)
	  begin

	  if exists (select * from AdvancedOrderProperties where orderid = @orderId)
	  begin
				Insert into AdvancedOrderProperties SELECT @NewOrderId
			  ,[StopLossPrice]
			  ,[TakeProfitPrice]
			  ,[TriggerPrice]
			  ,[TriggerPriceIsAboveCurrent]
			  ,[Notified]
			  ,[StopLossCommission]
			  ,[TriggerCommission]
		      FROM [cnx].[dbo].[AdvancedOrderProperties] with(nolock)
			  where OrderId = @orderId
	  end

	  update orderbook set orderstatusid = 16 where orderid = @orderId
	  --update RemoteOrderMappings set RemoteOrderMappingStatusId = 3 where orderid = @orderId

		 -- Insert into RemoteOrderMappings 
		 -- SELECT  
		 -- @NewOrderId
		 -- ,[ExecutePrice]
		 -- ,[Quantity]
		 -- ,[SubmitPrice]
		 -- ,[RemoteExchangeId]
		 -- ,null
		 -- ,null
		 -- ,null
		 -- ,null
		 -- ,[RemoteFee]
		 -- ,[OrderTypeId]
		 -- ,[OfferAssetTypeId]
		 -- ,[WantAssetTypeId]
		 -- ,7
		 -- ,[Message]
		 -- ,[Retry]
		 -- ,getdate()
		 -- ,getdate()
	  --FROM [cnx].[dbo].[RemoteOrderMappings] with (nolock) where orderid = @orderId

	  /****** Script for SelectTopNRows command from SSMS  ******/
		SELECT  [OrderId]
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
		  FROM [cnx].[dbo].[OrderBook] with (nolock) where orderid= @NewOrderId
	end
END
