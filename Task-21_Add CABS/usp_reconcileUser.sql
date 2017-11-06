USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_reconcileUser]    Script Date: 2017/11/06 14:37:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_reconcileUser]
@customerId int
AS
BEGIN
declare @CNYBalance decimal(18,8), @BTCBalance decimal(18,8), @ETHBalance decimal(18,8),@ETCBalance decimal(18,8) ,
@SKYBalance decimal(18,8),@SHLBalance decimal(18,8),@BCCBalance decimal(18,8),@DRGBalance decimal(18,8),@BTGBalance decimal(18,8), @CABSBalance decimal(18, 8) 
declare @UsedCNY decimal(18,8), @UsedBTC decimal(18,8), @UsedETH decimal(18,8),@UsedETC decimal(18,8), @UsedSKY decimal(18,8),
@UsedSHL decimal(18,8),@UsedBCC decimal(18,8),@UsedDRG decimal(18,8),@UsedBTG decimal(18,8), @UsedCABS decimal(18, 8)

-- CNY
select @CNYBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 1
select @UsedCNY = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 1
set @CNYBalance  = @CNYBalance - @UsedCNY
-- Deposit CNY
select @CNYBalance = @CNYBalance + isnull(sum(BankTransaction.TransactionAmount),0) from TransferRequest with (nolock)
inner join BankTransaction with(nolock) on TransferRequest.RequestId = BankTransaction.LinkRequestId
where Customerid = @CustomerId and TransferRequest.RequestTypeId = 5 and TransferRequest.RequestStatusId = 3
--withdrawal
select @CNYBalance = @CNYBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId in (3,4) and RequestStatusId = 3
--buy
select @CNYBalance = @CNYBalance -isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and O1.offerAssetTypeId = 1
--sell
select @CNYBalance = @CNYBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and O1.wantAssetTypeId = 1

--BTC
select @BTCBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 2
select @UsedBTC = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 2
set @BTCBalance  = @BTCBalance - @UsedBTC
-- Deposit btc
select @BTCBalance = @BTCBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 1 and RequestStatusId = 3
--withdrawal
select @BTCBalance = @BTCBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 2 and RequestStatusId = 3
--buy
select @BTCBalance = @BTCBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 2 
--sell
select @BTCBalance = @BTCBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 2

-- BTC_ETH 交易

--SKY COIN ICO  
select  @BTCBalance = @BTCBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and OfferAssetTypeId = 2 and WantAssetTypeId = 7


--BTC_SKY
--SELL
select  @BTCBalance = @BTCBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 7 and WantAssetTypeId = 2
--BUY
--select  @BTCBalance = @BTCBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
--left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
--where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and OfferAssetTypeId = 2 and WantAssetTypeId = 7

--BTC_BCC
select @BTCBalance = @BTCBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and WantAssetTypeId = 2 and offerAssetTypeid = 9

select @BTCBalance = @BTCBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 9 and offerAssetTypeid = 2


--ETH
select @ETHBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 5
select @UsedETH = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 5
set @ETHBalance  = @ETHBalance - @UsedETH
-- Deposit btc
select @ETHBalance = @ETHBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 8 and RequestStatusId = 3
--withdrawal
select @ETHBalance = @ETHBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 9 and RequestStatusId = 3
--buy
select @ETHBalance = @ETHBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 5
--sell
select @ETHBalance = @ETHBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 5

--ETH_BTC
select @ETHBalance = @ETHBalance + isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and WantAssetTypeId = 5 and offerAssetTypeid = 2

select @ETHBalance = @ETHBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 2 and offerAssetTypeid = 5

--ETH_SKY
select @ETHBalance = @ETHBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and WantAssetTypeId = 5 and offerAssetTypeid = 7

select @ETHBalance = @ETHBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 7 and offerAssetTypeid = 5

--ETC
select @ETCBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 6
select @UsedETC = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 6
set @ETCBalance  = @ETCBalance - @UsedETC
-- Deposit btc
select @ETCBalance = @ETCBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 10 and RequestStatusId = 3
--withdrawal
select @ETCBalance = @ETCBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 11 and RequestStatusId = 3
--buy
select @ETCBalance = @ETCBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 6
--sell
select @ETCBalance = @ETCBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 6



--SKY
select @SKYBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 7
select @UsedSKY = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 7
set @SKYBalance  = @SKYBalance - @UsedSKY
-- Deposit btc
select @SKYBalance = @SKYBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 12 and RequestStatusId = 3
--withdrawal
select @SKYBalance = @SKYBalance - isnull(sum(Amount),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 13 and RequestStatusId = 3
--buy
select @SKYBalance = @SKYBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 7
--sell
select @SKYBalance = @SKYBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 7

--BTC_SKY 
--2017-7-20
--add by steven
--Buy
--select @SKYBalance = @SKYBalance + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
--left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
--where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and OfferAssetTypeId = 2 and WantAssetTypeId = 7
--Sell
select @SKYBalance = @SKYBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 7 and WantAssetTypeId = 2


--SHELL
select @SHLBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 8
select @UsedSHL = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 8
set @SHLBalance  = @SHLBalance - @UsedSHL
-- Deposit 
select @SHLBalance = @SHLBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 14 and RequestStatusId = 3
--withdrawal
select @SHLBalance = @SHLBalance - isnull(sum(Amount),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 15 and RequestStatusId = 3
--buy
select @SHLBalance = @SHLBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 8
--sell
select @SHLBalance = @SHLBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 8

--BCC
select @BCCBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 9
select @UsedBCC = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 9
set @BCCBalance  = @BCCBalance - @UsedBCC
-- Deposit 
select @BCCBalance = @BCCBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 16 and RequestStatusId = 3
--withdrawal
select @BCCBalance = @BCCBalance - isnull(sum(Amount),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 17 and RequestStatusId = 3
--buy
select @BCCBalance = @BCCBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 9
--sell
select @BCCBalance = @BCCBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 9

--DRG
select @DRGBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 11
select @UsedDRG = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 11
set @DRGBalance  = @DRGBalance - @UsedDRG
-- Deposit 
select @DRGBalance = @DRGBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 20 and RequestStatusId = 3
--withdrawal
select @DRGBalance = @DRGBalance - isnull(sum(Amount),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 21 and RequestStatusId = 3
--buy
select @DRGBalance = @DRGBalance -isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and O1.offerAssetTypeId = 11
--sell
select @DRGBalance = @DRGBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and O1.wantAssetTypeId = 11
--convert from cny to drg
select @DRGBalance = @DRGBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 11
--convert from drg to cny
select @DRGBalance = @DRGBalance  - isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 11


--BTG
select @BTGBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 13
select @UsedBTG = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 13
set @BTGBalance  = @BTGBalance - @UsedBTG
-- Deposit btc
select @BTGBalance = @BTGBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 24 and RequestStatusId = 3
--withdrawal
select @BTGBalance = @BTGBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 25 and RequestStatusId = 3
--buy
select @BTGBalance = @BTGBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 13 
--sell
select @BTGBalance = @BTGBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 13

--CABS
select @CABSBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 12
select @UsedCABS = isnull(SUM(value),0) from Voucher with(nolock) where IsRedeemed = 1 and IssuedByCustomerId = @CustomerId and AssetTypeId = 12
set @CABSBalance  = @CABSBalance - @UsedCABS
-- Deposit btc
select @CABSBalance = @CABSBalance + isnull(sum(Amount),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 22 and RequestStatusId = 3
--withdrawal
select @CABSBalance = @CABSBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 23 and RequestStatusId = 3
--buy
select @CABSBalance = @CABSBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 12 
--sell
select @CABSBalance = @CABSBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 12

declare @CurrentCNY decimal(18,8), @CurrentBTC decimal(18,8), @CurrentETH decimal(18,8),@CurrentETC decimal(18,8),
@CurrentSKY decimal(18,8),@CurrentSHL decimal(18,8),@CurrentBCC decimal(18,8),@CurrentDRG decimal(18,8),@CurrentBTG decimal(18,8),
@CurrentCABS decimal(18, 8)
select  @CurrentCNY = balance from AssetBalance with (nolock) where CustomerId = @customerId AND AssetTypeId = 1
select  @CurrentBTC = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 2
select  @CurrentETH = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 5
select  @CurrentETC = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 6
select  @CurrentSKY = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 7
select  @CurrentSHL = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 8
select  @CurrentBCC = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =9
select  @CurrentDRG = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =11
select  @CurrentCABS = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =12
select  @CurrentBTG = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =13


declare @t table
(
	AssetTypeId int,
	CurrentBalance decimal(18,8),
	ReconcileBalance decimal(18,8),
	[Difference] decimal(18,8)
)

Insert into @t values (1,@CurrentCNY,@CNYBalance,@CurrentCNY - @CNYBalance)
Insert into @t values (2,@CurrentBTC,@BTCBalance,@CurrentBTC - @BTCBalance)
Insert into @t values (5,@CurrentETH,@ETHBalance,@CurrentETH - @ETHBalance)
Insert into @t values (6,@CurrentETC,@ETCBalance,@CurrentETC - @ETCBalance)
Insert into @t values (7,@CurrentSKY,@SKYBalance,@CurrentSKY - @SKYBalance)
Insert into @t values (8,@CurrentSHL,@SHLBalance,@CurrentSHL - @SHLBalance)
Insert into @t values (9,@CurrentBCC,@BCCBalance,@CurrentBCC - @BCCBalance)
Insert into @t values (11,@CurrentDRG,@DRGBalance,@CurrentDRG - @DRGBalance)
Insert into @t values (12,@CurrentCABS,@CABSBalance,@CurrentCABS - @CABSBalance)
Insert into @t values (13,@CurrentBTG,@BTGBalance,@CurrentBTG - @BTGBalance)
select * from @t
END
