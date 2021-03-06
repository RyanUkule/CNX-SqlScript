USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_ConvertSkyCoin]    Script Date: 2018/03/30 14:25:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_ConvertSkyCoin]
@ICOId int,
@quantity decimal(18,8),
@price decimal(18,8),
@customerId int
AS
BEGIN
begin try
begin tran
	declare @buyOrderId int, @sellOrderid int, @transactionId int

	insert into OrderBook(CustomerId, OrderTypeId, OfferAssetTypeId, WantAssetTypeId, Quantity, Price, OrderStatusId, OriginalOrderId,
		MarketOrder, ExpirationDate, TakeProfitOrderId, StopLossOrderId, UpdateDate, InsertDate, SaveDate, RemoteExchangeId, 
		RemoteExchangeOrderNumber, ParentOrderId, OrderClassId)
	select @customerId, 1, ico.OfferAssetTypeId, ico.WantAssetTypeId, @quantity, @price, 4, null, 0, null, null, null, getdate(), GETDATE(),
		getdate(), null, null, null, 1
	from [CoinToken] ck with (nolock) left join [ICO] ico with (nolock) on ck.ICOId = ico.ICOId
	where ck.ICOId = @ICOId and customerId = @customerId

	select @buyOrderId = SCOPE_IDENTITY()
---------------------------------------------------------------------------------------------------------------------------------------------
	insert into OrderBook(CustomerId, OrderTypeId, OfferAssetTypeId, WantAssetTypeId, Quantity, Price, OrderStatusId, OriginalOrderId,
		MarketOrder, ExpirationDate, TakeProfitOrderId, StopLossOrderId, UpdateDate, InsertDate, SaveDate, RemoteExchangeId, 
		RemoteExchangeOrderNumber, ParentOrderId, OrderClassId)
	select 2, 2, ico.WantAssetTypeId, ico.OfferAssetTypeId, @quantity, @price, 4, null, 0, null, null, null, getdate(), GETDATE(),
		getdate(), null, null, null, 1
	from [CoinToken] ck with (nolock) left join [ICO] ico with (nolock) on ck.ICOId = ico.ICOId
	where ck.ICOId = @ICOId and customerId = @customerId

	select @sellOrderid = SCOPE_IDENTITY()
---------------------------------------------------------------------------------------------------------------------------------------------
	insert into [Transaction](A_OrderId, A_Amount, A_Commission, B_OrderId, B_Amount, B_Commission, 
		Updatedate, InsertDate, SaveDate, TransactionTypeId)
	select @buyOrderId, @quantity * @price, 0, @sellOrderid, @quantity, 0, getdate(), getdate(), getdate(), 1

	select @transactionId = SCOPE_IDENTITY()
---------------------------------------------------------------------------------------------------------------------------------------------
	declare @btcBefore decimal(18,8), @btcAfter decimal(18,8), @skyBefore decimal(18,8), @skyAfter decimal(18,8), @advancedTransactionId int

	select @btcBefore = Balance, @btcAfter = Balance - @price * @quantity
	from AssetBalance where CustomerId = @customerId and AssetTypeId = 2
	select @skyBefore = Balance, @skyAfter = Balance + @quantity
	from AssetBalance where CustomerId = @customerId and AssetTypeId = 7

	insert into [AdvancedTransactionV1]([TransactionId], [TransactionTypeId], [A_OfferBalanceAfterTransaction], [A_WantBalanceAfterTransaction],
	[B_OfferBalanceAfterTransaction], [B_WantBalanceAfterTransaction], [Hash])
	select @transactionId, 1, @btcBefore, @skyBefore, @btcAfter, @skyAfter, null

	select @advancedTransactionId = SCOPE_IDENTITY()
---------------------------------------------------------------------------------------------------------------------------------------------
	select @buyOrderId as BuyOrderId, @sellOrderId as SellOrderId

	select [AdvanceTransactionId], [TransactionId], [A_OfferBalanceAfterTransaction], [A_WantBalanceAfterTransaction],
	[B_OfferBalanceAfterTransaction], [B_WantBalanceAfterTransaction], [Hash]
	from [AdvancedTransactionV1] with (nolock)
	where [AdvanceTransactionId] = @advancedTransactionId
---------------------------------------------------------------------------------------------------------------------------------------------
	declare @tokenId nvarchar(100)
	select @tokenId = TokenId from CoinToken with (nolock) where CustomerId = @customerId and ICOId = @ICOId
	
	insert into CoinTokenOrderMapping(ICOId, TokenId, OrderId, InsertDate)
	select @ICOId, @tokenId, @buyOrderId, getdate()
---------------------------------------------------------------------------------------------------------------------------------------------
	commit tran     
end try
begin	catch 
		rollback tran
		Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
		select Getdate(),0,0,'usp_ProcessTransactionv2 SKYCoin',ERROR_MESSAGE()
		throw 
end catch
END