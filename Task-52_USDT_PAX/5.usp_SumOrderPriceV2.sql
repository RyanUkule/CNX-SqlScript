USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_SumOrderPriceV2]    Script Date: 2018/11/01 17:03:55 ******/
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
,@UsedSHL decimal(18,8),@UsedZEC decimal(18, 8),@UsedDRG decimal(18,8),@UsedCABS decimal(18,8),@UsedUSDT decimal(18,8), @UsedLTC decimal(18,8),@UsedCCOIN decimal(18,8),
@SumSky decimal(18,8),@SumShl decimal(18,8),@SumCabs decimal(18,8),
@UsedDASH decimal(18, 8),@UsedZRX decimal(18,8),@UsedFUN decimal(18,8),@UsedTNB decimal(18,8), @UsedETP decimal(18,8),@Useducash DECIMAL(18,8),
@UsedOMG decimal(18, 8),@UsedRCN decimal(18,8),@UsedXRP decimal(18,8),@UsedEOS decimal(18,8), @UsedWAX DECIMAL(18,8), @UsedXLM decimal(18,8), 
@UsedTRIA decimal(18,8), @UsedBEZ decimal(18,8), @UsedSLRM decimal(18,8), @UsedPAX decimal(18,8)

declare @completedCNY decimal(18,8), @completedBTC decimal(18,8), @completedLTC decimal(18,8), @completedETH decimal(18,8), @completedETC decimal(18,8),
@completedSKY decimal(18,8), @completedSHL decimal(18,8), @completedBCC decimal(18,8), @completedZEC decimal(18,8), @completedDRG decimal(18,8),
@completedCABS decimal(18,8), @completedBTG decimal(18,8), @completedFCABS decimal(18,8), @completedUSDT decimal(18,8), @completedDASH decimal(18,8),
@completedZRX decimal(18,8), @completedFUN decimal(18,8), @completedTNB decimal(18,8), @completedETP decimal(18,8), @completedUCASH decimal(18,8),
@completedCCOIN decimal(18,8),@completedOMG decimal(18,8), @completedRCN decimal(18,8), @completedXRP decimal(18,8), 
@completedEOS decimal(18,8), @completedWAX decimal(18,8), @completedXLM decimal(18,8), 
@completedTRIA decimal(18,8), @completedBEZ decimal(18,8), @completedSLRM decimal(18,8), @completedPAX decimal(18,8)

--DRG 
select @UsedDRG = sum(case when MarketOrder = 0 then Price * Quantity when MarketOrder = 1 then Price end) 
from OrderBook WITH (nolock) where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in(2,10,12) and [OrderTypeId]=1 and [OfferAssetTypeId]=11)
	and customerId <> 2

select @UsedDRG = isnull(@UsedDRG, 0) + isnull(sum(Quantity), 0) 
from OrderBook WITH (nolock) where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in(2,10,12) and [OrderTypeId]=2 and [OfferAssetTypeId]=11)
	and customerId <> 2

select @completedDRG = sum(CompletedAmount * AveragePrice) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 1 and [OfferAssetTypeId]=11
and co.OrderStatusId in (2, 3, 10, 12)

select @completedDRG = isnull(@completedDRG, 0) + isnull(sum(CompletedAmount), 0) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=11
and co.OrderStatusId in (2, 3, 10, 12)
--------------------------------------------------------------------------------------------------------------------------------
--USDT
select @UsedUSDT = sum(case when MarketOrder = 0 then Price * Quantity when MarketOrder = 1 then Price end) 
from OrderBook WITH (nolock) where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in(2,10,12) and [OrderTypeId]=1 and [OfferAssetTypeId]=15)
	and customerId <> 2

select @completedUSDT = sum(CompletedAmount * AveragePrice) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and [OfferAssetTypeId]=15
and co.OrderStatusId in (2, 3, 10, 12)
--------------------------------------------------------------------------------------------------------------------------------
--BTC
select @UsedBTC = sum(case when MarketOrder = 0 then Quantity * Price when MarketOrder = 1 then Price end) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and OrderTypeId = 1 and [OfferAssetTypeId]=2) and customerId <> 2

select @UsedBTC = isnull(@UsedBTC, 0) + isnull(sum(Quantity), 0) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and OrderTypeId = 2 and [OfferAssetTypeId]=2) and customerId <> 2

select @completedBTC = sum(CompletedAmount * AveragePrice) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 1 and [OfferAssetTypeId]=2
and co.OrderStatusId in (2, 3, 10, 12)

select @completedBTC = isnull(@completedBTC, 0) + isnull(sum(CompletedAmount), 0) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=2
and co.OrderStatusId in (2, 3, 10, 12)
--------------------------------------------------------------------------------------------------------------------------------
--LTC
select @UsedLTC = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=3) and customerId <> 2

select @completedLTC = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=3
and co.OrderStatusId in (2, 3, 10, 12)
--------------------------------------------------------------------------------------------------------------------------------
--ETH
select @UsedETH = sum(case when OrderTypeId = 1 then Quantity * Price else Quantity end) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=5) and customerId <> 2

select @completedETH = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=5
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--ETC
select @UsedETC = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=6) and customerId <> 2

select @completedETC = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=6
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--SKY
select @UsedSKY = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=7) and customerId <> 2

select @completedSKY = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=7
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--SHL
select @UsedSHL = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=8) and customerId <> 2

select @completedSHL = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=8
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--BCC
select @UsedBCC = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=9) and customerId <> 2

select @completedBCC = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=9
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--ZEC
select @UsedZEC = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=10) and customerId <> 2

select @completedZEC = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=10
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--CABS
select @UsedCABS = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=12) and customerId <> 2

select @completedCABS = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=12
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--DASH
select @UsedDASH = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=16) and customerId <> 2

select @completedDASH = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=16
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--ZRX
select @UsedZRX = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=17) and customerId <> 2

select @completedZRX = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=17
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--FUN
select @UsedFUN = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=18) and customerId <> 2

select @completedFUN = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=18
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--TNB
select @UsedTNB = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=19) and customerId <> 2

select @completedTNB = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=19
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--ETP
select @UsedETP = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=20) and customerId <> 2

select @completedETP = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=20
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--UCASH
select @UsedUCASH = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=21) and customerId <> 2

select @completedUCASH = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=21
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--CCOIN
select @UsedCCOIN = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=22) and customerId <> 2

select @completedUCASH = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=22
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--OMG
select @UsedOMG = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=23) and customerId <> 2

select @completedOMG = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=23
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--RCN
select @UsedRCN = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=24) and customerId <> 2

select @completedRCN = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=24
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--XRP
select @UsedXRP = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=25) and customerId <> 2

select @completedXRP = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=25
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--EOS
select @UsedEOS = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=26) and customerId <> 2

select @completedEOS = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=26
and co.OrderStatusId in (2, 3, 10, 12)

----------------------------------------------------------------------------------------------------------------------------------
--WAX
select @UsedWAX = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=28) and customerId <> 2

select @completedWAX = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=28
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--XLM
select @UsedXLM = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=29) and customerId <> 2

select @completedXLM = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=29
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--TRIA
select @UsedTRIA = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=30) and customerId <> 2

select @completedXLM = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=30
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--BEZ
select @UsedBEZ = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=31) and customerId <> 2

select @completedXLM = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=31
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--SLRM
select @UsedSLRM = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=32) and customerId <> 2

select @completedXLM = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=32
and co.OrderStatusId in (2, 3, 10, 12)

--------------------------------------------------------------------------------------------------------------------------------
--PAX
select @UsedPAX = sum(Quantity) 
from OrderBook WITH (nolock) 
where OrderId in (select case when OriginalOrderId is null then OrderId else OriginalOrderId end 
	from [dbo].[OrderBook] WITH (nolock) where [CustomerId]=@customerId and 
	[OrderStatusId] in (2,10,12) 
	and [OfferAssetTypeId]=39) and customerId <> 2

select @completedPAX = sum(CompletedAmount) 
from CustomerOrder co inner join OrderBook o on co.OrderId = o.OrderId
where o.CustomerId = @customerId and OrderTypeId = 2 and [OfferAssetTypeId]=39
and co.OrderStatusId in (2, 3, 10, 12)
--------------------------------------------------------------------------------------------------------------------------------
select isnull(@UsedDRG,0) - isnull(@completedDRG, 0) as DRG,isnull(@UsedBTC,0) - isnull(@completedBTC, 0) AS BTC,isnull(@UsedLTC,0) - isnull(@completedLTC, 0) AS LTC ,
	   isnull(@UsedETH,0) - isnull(@completedETH, 0) AS ETH, isnull(@UsedETC,0) - isnull(@completedETC, 0) AS ETC, isnull(@UsedSKY,0) - isnull(@completedSKY, 0) AS SKY, 
	   ISNULL(@UsedSHL, 0) - isnull(@completedSHL, 0) AS SHL, ISNULL(@UsedBCC, 0) - isnull(@completedBCC, 0) AS BCC, ISNULL(@UsedZEC,0) - isnull(@completedZEC, 0) AS ZEC, 
	   ISNULL(@UsedCABS,0) - isnull(@completedCABS, 0) AS CABS, ISNULL(@UsedUSDT, 0) - isnull(@completedUSDT, 0) AS USDT, ISNULL(@UsedDASH,0) - isnull(@completedDASH, 0) AS DASH,
	   ISNULL(@UsedZRX,0) - isnull(@completedZRX, 0) AS ZRX, ISNULL(@UsedFUN,0) - isnull(@completedFUN, 0) AS FUN, ISNULL(@UsedTNB, 0) - isnull(@completedTNB, 0) AS TNB, 
	   ISNULL(@UsedETP, 0) - isnull(@completedETP, 0) AS ETP,ISNULL(@UsedUCASH, 0) - isnull(@completedUCASH, 0) AS UCASH,
	   ISNULL(@UsedOMG,0) - isnull(@completedOMG, 0) AS OMG, ISNULL(@UsedRCN,0) - isnull(@completedRCN, 0) AS RCN, ISNULL(@UsedXRP, 0) - isnull(@completedXRP, 0) AS XRP, 
	   ISNULL(@UsedEOS,0) - isnull(@completedEOS, 0) AS EOS, ISNULL(@UsedWAX, 0) - isnull(@completedWAX, 0) AS WAX, ISNULL(@UsedXLM, 0) - isnull(@completedXLM, 0) AS XLM, 
	   ISNULL(@UsedTRIA, 0) - isnull(@completedTRIA, 0) AS TRIA, ISNULL(@UsedBEZ, 0) - isnull(@completedBEZ, 0) AS BEZ, ISNULL(@UsedSLRM, 0) - isnull(@completedSLRM, 0) AS SLRM, 
	   isnull(@SumSKY,0) as SumSKY, isnull(@SumSHL,0) as SumSHL, isnull(@SumCABS,0) as SumCABS
END


