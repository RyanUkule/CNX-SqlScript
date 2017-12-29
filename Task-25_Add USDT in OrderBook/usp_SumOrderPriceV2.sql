USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_SumOrderPriceV2]    Script Date: 2017/12/21 16:39:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_SumOrderPriceV2]
@customerId int
AS
BEGIN

SET NOCOUNT ON;	
declare @UsedCNY decimal(18,8), @UsedBTC decimal(18,8), @UsedETH decimal(18,8), @UsedETC decimal(18,8), @UsedSKY decimal(18,8), @UsedBCC decimal(18,8)
,@UsedSHL decimal(18,8),@UsedZEC decimal(18, 8),@UsedDRG decimal(18,8),@UsedCABS decimal(18,8),@UsedUSDT decimal(18,8),
@SumSky decimal(18,8),@SumShl decimal(18,8),@SumCabs decimal(18,8)

--DRG 
select @UsedDRG = sum(case when MarketOrder = 0 then Price * Quantity when MarketOrder = 1 then Price end) 
from OrderBook WITH (nolock) where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in(2,10,12) and [OrderTypeId]=1 and [OfferAssetTypeId]=11)
	and customerId <> 2

--USDT
select @UsedUSDT = sum(
			case when MarketOrder = 0 then Price * Quantity 
				 when MarketOrder = 1 then Price end) 
from OrderBook WITH (nolock) where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in(2,10,12) and [OrderTypeId]=1 and [OfferAssetTypeId]=15)
	and customerId <> 2

--BTC
select @UsedBTC = sum(
			case when WantAssetTypeId <> 11 and WantAssetTypeId <> 15
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
			case when WantAssetTypeId <> 11 and WantAssetTypeId <> 15
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
			case when WantAssetTypeId <> 11 and WantAssetTypeId <> 15
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
			case when WantAssetTypeId <> 11 and WantAssetTypeId <> 15
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
			case when WantAssetTypeId <> 11 and WantAssetTypeId <> 15
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
			case when WantAssetTypeId <> 11 and WantAssetTypeId <> 15
					then Quantity * Price
				else Quantity
			end)
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=9) and customerId <> 2

--ZEC
select @UsedZEC = sum(
			case when WantAssetTypeId <> 11 and WantAssetTypeId <> 15
					then Quantity * Price
				else Quantity
			end)
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=10) and customerId <> 2

--CABS
select @UsedCABS = sum(
			case when WantAssetTypeId <> 11 
					then Quantity * Price
				else Quantity
			end)
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=12) and customerId <> 2

--select @UsedSKY = sum(Quantity*Price) from OrderBook WITH (nolock) 
--where [CustomerId]=@customerId and [OrderStatusId] in (4) and [OrderTypeId]=2 and [OfferAssetTypeId]=7

--select @SumSKY = sum(Quantity) from OrderBook WITH (nolock) 
--where [OrderStatusId] in (4) and [OrderTypeId]=2 and [OfferAssetTypeId]=7

select isnull(@UsedDRG,0) as DRG,isnull(@UsedBTC,0) AS BTC ,isnull(@UsedETH,0) AS ETH, 
	   isnull(@UsedETC,0) AS ETC, isnull(@UsedSKY,0) AS SKY, ISNULL(@UsedSHL, 0) AS SHL, ISNULL(@UsedBCC, 0) AS BCC, 
	   ISNULL(@UsedZEC,0) AS ZEC, ISNULL(@UsedCABS,0) AS CABS, ISNULL(@UsedUSDT, 0) AS USDT,
	   isnull(@SumSKY,0) as SumSKY, isnull(@SumSHL,0) as SumSHL, isnull(@SumCABS,0) as SumCABS
END


