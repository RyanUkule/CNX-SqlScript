CREATE PROCEDURE [dbo].[usp_GetICOCompleteOrder]
@tokenId int
AS
BEGIN
	select 
	   O.[OrderId]
      ,O.[CustomerId]
	  ,C.UserName
      ,[OrderTypeId]
      ,[OfferAssetTypeId]
      ,[WantAssetTypeId]
      ,[Quantity]
      ,[Price]
	  ,[CompletedAmount]
      ,O.[OrderStatusId]
      ,[OriginalOrderId]
      ,[MarketOrder]
      ,[ExpirationDate]
      ,[TakeProfitOrderId]
      ,[StopLossOrderId]
      ,O.[UpdateDate]
      ,O.[InsertDate]
      ,O.[SaveDate]
      ,[RemoteExchangeId]
      ,[RemoteExchangeOrderNumber]
      ,[ParentOrderId]
      ,[OrderClassId]
      ,[IsTakeOrder]
	from OrderBook O with (nolock) 
	INNER JOIN CoinTokenOrderMapping M with (nolock) ON  O.OrderId = M.OrderId
	INNER JOIN CustomerOrder CO WITH (NOLOCK) ON CO.OrderId = O.OrderId
	LEFT JOIN Customer C WITH (NOLOCK) ON C.customerId = O.customerId
	where TokenId = @tokenId
	and O.OrderStatusId = 4
END