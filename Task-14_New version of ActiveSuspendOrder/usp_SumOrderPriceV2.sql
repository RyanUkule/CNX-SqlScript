USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_SumOrderPriceV2]    Script Date: 2017/08/14 16:54:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_SumOrderPriceV2]
@customerId int
AS
BEGIN

SET NOCOUNT ON;	
declare @UsedCNY decimal(18,8), @UsedBTC decimal(18,8), @UsedETH decimal(18,8), @UsedETC decimal(18,8), @UsedSKY decimal(18,8), @UsedBCC decimal(18,8), @SumSky decimal(18,8),
@UsedSHL decimal(18,8), @SumShl decimal(18,8)

--CNY 
select @UsedCNY = sum(case when MarketOrder = 0 then Price * Quantity when MarketOrder = 1 then Price end) 
from OrderBook WITH (nolock) where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in(2,10,12) and [OrderTypeId]=1 and [OfferAssetTypeId]=1)
	and customerId <> 2

--BTC
select @UsedBTC = sum(
			case when WantAssetTypeId <> 1 
					then Quantity * Price
				else Quantity
			end) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=2) and customerId <> 2

--ETH
select @UsedETH = sum(
			case when WantAssetTypeId <> 1 
					then Quantity * Price
				else Quantity
			end) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=5) and customerId <> 2

--ETC
select @UsedETC = sum(
			case when WantAssetTypeId <> 1 
					then Quantity * Price
				else Quantity
			end)
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=6) and customerId <> 2

--SKY
select @UsedSKY = sum(
			case when WantAssetTypeId <> 1 
					then Quantity * Price
				else Quantity
			end)
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=7) and customerId <> 2

--SHL
select @UsedSHL = sum(
			case when WantAssetTypeId <> 1 
					then Quantity * Price
				else Quantity
			end)
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=8) and customerId <> 2


--BCC
select @UsedBCC = sum(
			case when WantAssetTypeId <> 1 
					then Quantity * Price
				else Quantity
			end)
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=9) and customerId <> 2

--select @UsedSKY = sum(Quantity*Price) from OrderBook WITH (nolock) 
--where [CustomerId]=@customerId and [OrderStatusId] in (4) and [OrderTypeId]=2 and [OfferAssetTypeId]=7

--select @SumSKY = sum(Quantity) from OrderBook WITH (nolock) 
--where [OrderStatusId] in (4) and [OrderTypeId]=2 and [OfferAssetTypeId]=7

select isnull(@UsedCNY,0) as CNY,isnull(@UsedBTC,0) AS BTC ,isnull(@UsedETH,0) AS ETH, 
	   isnull(@UsedETC,0) AS ETC, isnull(@UsedSKY,0) AS SKY, ISNULL(@UsedSHL, 0) AS SHL, ISNULL(@UsedBCC, 0) AS BCC, isnull(@SumSKY,0) as SumSKY, isnull(@SumSHL,0) as SumSHL
END


