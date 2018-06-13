USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_reconcileUser]    Script Date: 2018/06/13 15:04:48 ******/
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
@SKYBalance decimal(18,8),@SHLBalance decimal(18,8),@BCCBalance decimal(18,8),@DRGBalance decimal(18,8),@BTGBalance decimal(18,8), 
@CABSBalance decimal(18, 8), @FCABSBalance decimal(18, 8), @USDTBalance decimal(18,8), @ZECBalance decimal(18,8), @LTCBalance decimal(18,8),
@DASHBalance decimal(18, 8), @ZRXBalance decimal(18, 8), @FUNBalance decimal(18,8), @TNBBalance decimal(18,8), @ETPBalance decimal(18,8),
@UCASHBalance decimal(18, 8), @CCOINBalance decimal(18, 8), 
@OMGBalance decimal(18, 8), @RCNBalance decimal(18, 8), @XRPBalance decimal(18, 8), @EOSBalance decimal(18, 8), @WAXBalance decimal(18, 8),
@XLMBalance decimal(18, 8)
declare @UsedCNY decimal(18,8), @UsedBTC decimal(18,8), @UsedETH decimal(18,8),@UsedETC decimal(18,8), @UsedSKY decimal(18,8),
@UsedSHL decimal(18,8),@UsedBCC decimal(18,8),@UsedDRG decimal(18,8),@UsedBTG decimal(18,8), @UsedCABS decimal(18, 8), 
@UsedFCABS decimal(18, 8), @UsedUSDT decimal(18,8), @UsedZEC decimal(18,8), @UsedLTC decimal(18,8),
@UsedDASH decimal(18, 8), @UsedZRX decimal(18, 8), @UsedFUN decimal(18,8), @UsedTNB decimal(18,8), @UsedETP decimal(18,8),
@UsedUCASH decimal(18,8), @UsedCCOIN decimal(18, 8), 
@UsedOMG decimal(18, 8), @UsedRCN decimal(18, 8), @UsedXRP decimal(18, 8), @UsedEOS decimal(18, 8), @UsedWAX decimal(18, 8),
@UsedXLM decimal(18, 8)
----------------------------------------------------------------------------------------------------------------------------------------------
-- CNY
select @CNYBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 1
select @UsedCNY = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 1
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
----------------------------------------------------------------------------------------------------------------------------------------------
-- USDT
select @USDTBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 15
select @UsedUSDT = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 15
set @USDTBalance  = @USDTBalance - @UsedUSDT
-- Deposit USDT
select @USDTBalance = @USDTBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 28 and RequestStatusId = 3
--withdrawal
select @USDTBalance = @USDTBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 29 and RequestStatusId = 3
--buy
select @USDTBalance = @USDTBalance -isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and O1.offerAssetTypeId = 15
--sell
select @USDTBalance = @USDTBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and O1.wantAssetTypeId = 15
--interest
select @USDTBalance = @USDTBalance + ISNULL(sum(Amount), 0) from [RewardTransaction] T with(nolock)
where T.CustomerId = @customerId and T.AssetTypeId = 15
----------------------------------------------------------------------------------------------------------------------------------------------
--BTC
select @BTCBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 2
select @UsedBTC = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 2
set @BTCBalance  = @BTCBalance - @UsedBTC
-- Deposit btc
select @BTCBalance = @BTCBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 1 and RequestStatusId = 3
--withdrawal
select @BTCBalance = @BTCBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 2 and RequestStatusId = 3
--BTC作为次货币
--buy
select @BTCBalance = @BTCBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 2 
--sell
select @BTCBalance = @BTCBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 2

--BTC作为主货币
--buy
select @BTCBalance = @BTCBalance  - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and OfferAssetTypeId = 2
--sell
select @BTCBalance = @BTCBalance  + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and WantAssetTypeId = 2 
----------------------------------------------------------------------------------------------------------------------------------------------
--LTC
select @LTCBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 3
select @UsedLTC = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 3
set @LTCBalance  = @LTCBalance - @UsedLTC
-- Deposit LTC
select @LTCBalance = @LTCBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 6 and RequestStatusId = 3
--withdrawal
select @LTCBalance = @LTCBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 7 and RequestStatusId = 3
--buy
select @LTCBalance = @LTCBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 3 
--sell
select @LTCBalance = @LTCBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 3
----------------------------------------------------------------------------------------------------------------------------------------------
--ETH
select @ETHBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 5
select @UsedETH = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 5
set @ETHBalance  = @ETHBalance - @UsedETH
-- Deposit btc
select @ETHBalance = @ETHBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 8 and RequestStatusId = 3
--withdrawal
select @ETHBalance = @ETHBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 9 and RequestStatusId = 3
--ETH作为次货币
--buy
select @ETHBalance = @ETHBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 5
--sell
select @ETHBalance = @ETHBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 5
--ETH作为主货币
--Buy
select @ETHBalance = @ETHBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and offerAssetTypeid = 5
--Sell
select @ETHBalance = @ETHBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and WantAssetTypeId = 5 
----------------------------------------------------------------------------------------------------------------------------------------------
--ETC
select @ETCBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 6
select @UsedETC = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 6
set @ETCBalance  = @ETCBalance - @UsedETC
-- Deposit btc
select @ETCBalance = @ETCBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 10 and RequestStatusId = 3
--withdrawal
select @ETCBalance = @ETCBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 11 and RequestStatusId = 3
--ETC作为次货币
--buy
select @ETCBalance = @ETCBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 6
--sell
select @ETCBalance = @ETCBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 6
--ETC作为主货币
--Buy
select @ETCBalance = @ETCBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and offerAssetTypeid = 6
--Sell
select @ETCBalance = @ETCBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and WantAssetTypeId = 6 
----------------------------------------------------------------------------------------------------------------------------------------------
--SKY
select @SKYBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 7
select @UsedSKY = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 7
set @SKYBalance  = @SKYBalance - @UsedSKY
-- Deposit btc
select @SKYBalance = @SKYBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 12 and RequestStatusId = 3
--withdrawal
select @SKYBalance = @SKYBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 13 and RequestStatusId = 3
--buy
select @SKYBalance = @SKYBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 7
--sell
select @SKYBalance = @SKYBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 7
----------------------------------------------------------------------------------------------------------------------------------------------
--SHELL
select @SHLBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 8
select @UsedSHL = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 8
set @SHLBalance  = @SHLBalance - @UsedSHL
-- Deposit 
select @SHLBalance = @SHLBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 14 and RequestStatusId = 3
--withdrawal
select @SHLBalance = @SHLBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 15 and RequestStatusId = 3
--buy
select @SHLBalance = @SHLBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 8
--sell
select @SHLBalance = @SHLBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 8
----------------------------------------------------------------------------------------------------------------------------------------------
--BCC
select @BCCBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 9
select @UsedBCC = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 9
set @BCCBalance  = @BCCBalance - @UsedBCC
-- Deposit 
select @BCCBalance = @BCCBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 16 and RequestStatusId = 3
--withdrawal
select @BCCBalance = @BCCBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 17 and RequestStatusId = 3
--BCC作为次货币
--buy
select @BCCBalance = @BCCBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 9
--sell
select @BCCBalance = @BCCBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and OfferAssetTypeId = 9
--BCC作为主货币
--Buy
select @BCCBalance = @BCCBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and offerAssetTypeid = 9
--Sell
select @BCCBalance = @BCCBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and WantAssetTypeId = 9 
----------------------------------------------------------------------------------------------------------------------------------------------
--ZEC
select @ZECBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 10
select @UsedZEC = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 10
set @ZECBalance  = @ZECBalance - @UsedZEC
--buy
select @ZECBalance = @ZECBalance + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and O1.wantAssetTypeId = 10
--sell
select @ZECBalance = @ZECBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and O1.offerAssetTypeId = 10
----------------------------------------------------------------------------------------------------------------------------------------------
--DRG
select @DRGBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 11
select @UsedDRG = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 11
set @DRGBalance  = @DRGBalance - @UsedDRG
-- Deposit 
select @DRGBalance = @DRGBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 20 and RequestStatusId = 3
--withdrawal
select @DRGBalance = @DRGBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 21 and RequestStatusId = 3
--DRG作为主货币
--buy
select @DRGBalance = @DRGBalance - isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and O1.offerAssetTypeId = 11
--sell
select @DRGBalance = @DRGBalance + isnull(sum(A_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and O1.wantAssetTypeId = 11
--DRG作为次货币
--Buy
select @DRGBalance = @DRGBalance + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.A_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 1 and WantAssetTypeId = 11
--Sell
select @DRGBalance = @DRGBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O1 with(nolock) on T.B_OrderId = O1.OrderId 
where O1.CustomerId = @CustomerId and O1.OrderTypeId = 2 and offerAssetTypeId = 11 
----------------------------------------------------------------------------------------------------------------------------------------------
--BTG
select @BTGBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 13
select @UsedBTG = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 13
set @BTGBalance  = @BTGBalance - @UsedBTG
-- Deposit btc
select @BTGBalance = @BTGBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
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
----------------------------------------------------------------------------------------------------------------------------------------------
--CABS
select @CABSBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 12
select @UsedCABS = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 12
set @CABSBalance  = @CABSBalance - @UsedCABS
-- Deposit btc
select @CABSBalance = @CABSBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
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
----------------------------------------------------------------------------------------------------------------------------------------------
--FCABS
select @FCABSBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 14
select @UsedFCABS = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 14
set @FCABSBalance  = @FCABSBalance - @UsedFCABS
-- Deposit btc
select @FCABSBalance = @FCABSBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 26 and RequestStatusId = 3
--withdrawal
select @FCABSBalance = @FCABSBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 27 and RequestStatusId = 3
--buy
select @FCABSBalance = @FCABSBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 14 
--sell
select @FCABSBalance = @FCABSBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 14
--extra trade ETH换FCABS
select @FCABSBalance = @FCABSBalance + isnull(sum(A_Amount + A_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and WantAssetTypeId = 14
----------------------------------------------------------------------------------------------------------------------------------------------
--DASH
select @DASHBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 16
select @UsedDASH = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 16
set @DASHBalance  = @DASHBalance - @UsedDASH
-- Deposit
select @DASHBalance = @DASHBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 30 and RequestStatusId = 3
--withdrawal
select @DASHBalance = @DASHBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 31 and RequestStatusId = 3
--buy
select @DASHBalance = @DASHBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 16 
--sell
select @DASHBalance = @DASHBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 16
----------------------------------------------------------------------------------------------------------------------------------------------
--ZRX
select @ZRXBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 17
select @UsedZRX = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 17
set @ZRXBalance  = @ZRXBalance - @UsedZRX
-- Deposit
select @ZRXBalance = @ZRXBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 32 and RequestStatusId = 3
--withdrawal
select @ZRXBalance = @ZRXBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 33 and RequestStatusId = 3
--buy
select @ZRXBalance = @ZRXBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 17 
--sell
select @ZRXBalance = @ZRXBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 17
----------------------------------------------------------------------------------------------------------------------------------------------
--FUN
select @FUNBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 18
select @UsedFUN = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 18
set @FUNBalance  = @FUNBalance - @UsedFUN
-- Deposit
select @FUNBalance = @FUNBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 34 and RequestStatusId = 3
--withdrawal
select @FUNBalance = @FUNBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 35 and RequestStatusId = 3
--buy
select @FUNBalance = @FUNBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 18 
--sell
select @FUNBalance = @FUNBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 18
----------------------------------------------------------------------------------------------------------------------------------------------
--TNB
select @TNBBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 19
select @UsedTNB = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 19
set @TNBBalance  = @TNBBalance - @UsedTNB
-- Deposit
select @TNBBalance = @TNBBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 36 and RequestStatusId = 3
--withdrawal
select @TNBBalance = @TNBBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 37 and RequestStatusId = 3
--buy
select @TNBBalance = @TNBBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 19 
--sell
select @TNBBalance = @TNBBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 19
----------------------------------------------------------------------------------------------------------------------------------------------
--ETP
select @ETPBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 20
select @UsedETP = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 20
set @ETPBalance  = @ETPBalance - @UsedETP
-- Deposit
select @ETPBalance = @ETPBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 38 and RequestStatusId = 3
--withdrawal
select @ETPBalance = @ETPBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 39 and RequestStatusId = 3
--buy
select @ETPBalance = @ETPBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 20 
--sell
select @ETPBalance = @ETPBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 20
----------------------------------------------------------------------------------------------------------------------------------------------
--UCASH
select @UCASHBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 21
select @UsedUCASH = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 21
set @UCASHBalance  = @UCASHBalance - @UsedUCASH
-- Deposit
select @UCASHBalance = @UCASHBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 40 and RequestStatusId = 3
--withdrawal
select @UCASHBalance = @UCASHBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 41 and RequestStatusId = 3
--buy
select @UCASHBalance = @UCASHBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 21 
--sell
select @UCASHBalance = @UCASHBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 21
----------------------------------------------------------------------------------------------------------------------------------------------
--CCOIN
select @CCOINBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 22
select @UsedCCOIN = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 22
set @CCOINBalance  = @CCOINBalance - @UsedCCOIN
-- Deposit
select @CCOINBalance = @CCOINBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 54 and RequestStatusId = 3
--withdrawal
select @CCOINBalance = @CCOINBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 55 and RequestStatusId = 3
--buy
select @CCOINBalance = @CCOINBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 22 
--sell
select @CCOINBalance = @CCOINBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 22
----------------------------------------------------------------------------------------------------------------------------------------------
--OMG
select @OMGBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 23
select @UsedOMG = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 23
set @OMGBalance  = @OMGBalance - @UsedOMG
-- Deposit
select @OMGBalance = @OMGBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 42 and RequestStatusId = 3
--withdrawal
select @OMGBalance = @OMGBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 43 and RequestStatusId = 3
--buy
select @OMGBalance = @OMGBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 23 
--sell
select @OMGBalance = @OMGBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 23
----------------------------------------------------------------------------------------------------------------------------------------------
--RCN
select @RCNBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 24
select @UsedRCN = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 24
set @RCNBalance  = @RCNBalance - @UsedRCN
-- Deposit
select @RCNBalance = @RCNBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 44 and RequestStatusId = 3
--withdrawal
select @RCNBalance = @RCNBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 45 and RequestStatusId = 3
--buy
select @RCNBalance = @RCNBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 24 
--sell
select @RCNBalance = @RCNBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 24
----------------------------------------------------------------------------------------------------------------------------------------------
--XRP
select @XRPBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 25
select @UsedXRP = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 25
set @XRPBalance  = @XRPBalance - @UsedXRP
-- Deposit
select @XRPBalance = @XRPBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 46 and RequestStatusId = 3
--withdrawal
select @XRPBalance = @XRPBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 47 and RequestStatusId = 3
--buy
select @XRPBalance = @XRPBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 25 
--sell
select @XRPBalance = @XRPBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 25
----------------------------------------------------------------------------------------------------------------------------------------------
--EOS
select @EOSBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 26
select @UsedEOS = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 26
set @EOSBalance  = @EOSBalance - @UsedEOS
-- Deposit
select @EOSBalance = @EOSBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 48 and RequestStatusId = 3
--withdrawal
select @EOSBalance = @EOSBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 49 and RequestStatusId = 3
--buy
select @EOSBalance = @EOSBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 26 
--sell
select @EOSBalance = @EOSBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 26
----------------------------------------------------------------------------------------------------------------------------------------------
--WAX
select @WAXBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 28
select @UsedWAX = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 28
set @WAXBalance  = @WAXBalance - @UsedWAX
-- Deposit
select @WAXBalance = @WAXBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 52 and RequestStatusId = 3
--withdrawal
select @WAXBalance = @WAXBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 53 and RequestStatusId = 3
--buy
select @WAXBalance = @WAXBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 28 
--sell
select @WAXBalance = @WAXBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 28
----------------------------------------------------------------------------------------------------------------------------------------------
--XLM
select @XLMBalance= isnull(SUM(Value),0) from Voucher with(nolock) where RedeemedByCustomerId = @CustomerId and AssetTypeId = 29
select @UsedXLM = isnull(SUM(value),0) from Voucher with(nolock) where VoucherStatusId = 3 and IssuedByCustomerId = @CustomerId and AssetTypeId = 29
set @XLMBalance  = @XLMBalance - @UsedXLM
-- Deposit
select @XLMBalance = @XLMBalance + isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where Customerid = @CustomerId and RequestTypeId = 56 and RequestStatusId = 3
--withdrawal
select @XLMBalance = @XLMBalance - isnull(sum(Amount),0) - isnull(sum(Commision),0) from TransferRequest with (nolock)
where CustomerId = @CustomerId and RequestTypeId = 57 and RequestStatusId = 3
--buy
select @XLMBalance = @XLMBalance  + isnull(sum(B_Amount),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.A_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 1 and WantAssetTypeId = 29 
--sell
select @XLMBalance = @XLMBalance - isnull(sum(B_Amount + B_Commission),0) from [Transaction]  T with(nolock)  
left join OrderBook O with(nolock) on T.B_OrderId = O.OrderId 
where O.CustomerId = @CustomerId and O.OrderTypeId = 2 and OfferAssetTypeId = 29
----------------------------------------------------------------------------------------------------------------------------------------------
declare @CurrentCNY decimal(18,8), @CurrentBTC decimal(18,8), @CurrentETH decimal(18,8),@CurrentETC decimal(18,8),
@CurrentSKY decimal(18,8),@CurrentSHL decimal(18,8),@CurrentBCC decimal(18,8),@CurrentDRG decimal(18,8),@CurrentBTG decimal(18,8),
@CurrentCABS decimal(18, 8), @CurrentFCABS decimal(18, 8), @CurrentUSDT decimal(18,8), @CurrentZEC decimal(18,8), @CurrentLTC decimal(18,8),
@CurrentDASH decimal(18, 8), @CurrentZRX decimal(18, 8), @CurrentFUN decimal(18,8), @CurrentTNB decimal(18,8), @CurrentETP decimal(18,8),
@CurrentUCASH decimal(18, 8), @CurrentCCOIN decimal(18, 8)
, @CurrentOMG decimal(18, 8), @CurrentRCN decimal(18, 8), @CurrentXRP decimal(18, 8)
, @CurrentEOS decimal(18, 8), @CurrentWAX decimal(18, 8), @CurrentXLM decimal(18, 8)

select  @CurrentCNY = balance from AssetBalance with (nolock) where CustomerId = @customerId AND AssetTypeId = 1
select  @CurrentBTC = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 2
select  @CurrentLTC = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 3
select  @CurrentETH = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 5
select  @CurrentETC = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 6
select  @CurrentSKY = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 7
select  @CurrentSHL = balance from AssetBalance with (nolock) where customerid	= @customerId and assettypeid = 8
select  @CurrentBCC = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =9
select  @CurrentZEC = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =10
select  @CurrentDRG = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =11
select  @CurrentCABS = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =12
select  @CurrentBTG = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =13
select  @CurrentFCABS = balance from AssetBalance with(nolock) where customerid = @customerId and assettypeId =14
select @CurrentUSDT = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 15
select @CurrentDASH = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 16
select @CurrentZRX = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 17
select @CurrentFUN = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 18
select @CurrentTNB = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 19
select @CurrentETP = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 20
select @CurrentUCASH = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 21
select @CurrentCCOIN = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 22
select @CurrentOMG = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 23
select @CurrentRCN = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 24
select @CurrentXRP = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 25
select @CurrentEOS = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 26
select @CurrentWAX = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 28
select @CurrentXLM = balance from AssetBalance with(nolock) where CustomerId = @customerId and AssetTypeId = 29

declare @t table
(
	AssetTypeId int,
	CurrentBalance decimal(18,8),
	ReconcileBalance decimal(18,8),
	[Difference] decimal(18,8)
)

Insert into @t values (1,@CurrentCNY,@CNYBalance,@CurrentCNY - @CNYBalance)
Insert into @t values (2,@CurrentBTC,@BTCBalance,@CurrentBTC - @BTCBalance)
Insert into @t values (3,@CurrentLTC,@LTCBalance,@CurrentLTC - @LTCBalance)
Insert into @t values (5,@CurrentETH,@ETHBalance,@CurrentETH - @ETHBalance)
Insert into @t values (6,@CurrentETC,@ETCBalance,@CurrentETC - @ETCBalance)
Insert into @t values (7,@CurrentSKY,@SKYBalance,@CurrentSKY - @SKYBalance)
Insert into @t values (8,@CurrentSHL,@SHLBalance,@CurrentSHL - @SHLBalance)
Insert into @t values (9,@CurrentBCC,@BCCBalance,@CurrentBCC - @BCCBalance)
Insert into @t values (10,@CurrentZEC,@ZECBalance,@CurrentZEC - @ZECBalance)
Insert into @t values (11,@CurrentDRG,@DRGBalance,@CurrentDRG - @DRGBalance)
Insert into @t values (12,@CurrentCABS,@CABSBalance,@CurrentCABS - @CABSBalance)
Insert into @t values (13,@CurrentBTG,@BTGBalance,@CurrentBTG - @BTGBalance)
Insert into @t values (14,@CurrentFCABS,@FCABSBalance,@CurrentFCABS - @FCABSBalance)
Insert into @t values (15,@CurrentUSDT,@USDTBalance,@CurrentUSDT - @USDTBalance)
Insert into @t values (16,@CurrentDASH,@DASHBalance,@CurrentDASH - @DASHBalance)
Insert into @t values (17,@CurrentZRX,@ZRXBalance,@CurrentZRX - @ZRXBalance)
Insert into @t values (18,@CurrentFUN,@FUNBalance,@CurrentFUN - @FUNBalance)
Insert into @t values (19,@CurrentTNB,@TNBBalance,@CurrentTNB - @TNBBalance)
Insert into @t values (20,@CurrentETP,@ETPBalance,@CurrentETP - @ETPBalance)
Insert into @t values (21,@CurrentUCASH,@UCASHBalance,@CurrentUCASH - @UCASHBalance)
Insert into @t values (22,@CurrentCCOIN,@CCOINBalance,@CurrentCCOIN - @CCOINBalance)
Insert into @t values (23,@CurrentOMG,@OMGBalance,@CurrentOMG - @OMGBalance)
Insert into @t values (24,@CurrentRCN,@RCNBalance,@CurrentRCN - @RCNBalance)
Insert into @t values (25,@CurrentXRP,@XRPBalance,@CurrentXRP - @XRPBalance)
Insert into @t values (26,@CurrentEOS,@EOSBalance,@CurrentEOS - @EOSBalance)
Insert into @t values (28,@CurrentWAX,@WAXBalance,@CurrentWAX - @WAXBalance)
Insert into @t values (29,@CurrentXLM,@XLMBalance,@CurrentXLM - @XLMBalance)
select * from @t
END


