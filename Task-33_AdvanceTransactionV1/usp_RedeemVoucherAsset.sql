USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_RedeemVoucherAsset]    Script Date: 2018/04/03 13:52:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_RedeemVoucherAsset]
@IssueCustomerId int,
@RedeemCustomerId int,
@AssetTypeId int,
@value decimal(20,8),
@voucherId varchar(30),
@updateDate Datetime,
@redeemHash nvarchar(500),
@assignHash nvarchar(500),
@oldredeemHash nvarchar(500),
@oldassignHash nvarchar(500)
AS
BEGIN
begin tran
begin try
	declare @AassetTypeId int = null, @BassetTypeId int = null, @AllowRedeemDate datetime = null

	select @AassetTypeId = AssetTypeId from AssetBalance 
		where customerId = @RedeemCustomerId and AssetTypeId = @AssetTypeId --and ([hash]=@oldredeemHash or [hash] is null)
	select @BassetTypeId = AssetTypeId from AssetBalance 
		where customerId = @IssueCustomerId and AssetTypeId = @AssetTypeId --and ([hash]=@oldassignHash or [hash] is null)
	select @AllowRedeemDate = AllowRedeemDate  from Voucher where VoucherId = @voucherId

	if(@AassetTypeId is not null and @BassetTypeId is not null)
	begin
		Update AssetBalance 
			set 
				Balance = Balance + @value,
				FrozenBalance = case when @AllowRedeemDate is not null and @AllowRedeemDate > GETDATE()
										then FrozenBalance + @value
									 else FrozenBalance
								end,
				UpdateDate = @updateDate, 
				[Hash] = @redeemHash
		where customerId = @RedeemCustomerId and AssetTypeId = @AssetTypeId --and ([hash]=@oldredeemHash or [hash] is null)

		Update AssetBalance set Balance =  Balance - @value , FrozenBalance = FrozenBalance - @value, updateDate = @updateDate, [hash] = @assignHash
		where customerId = @IssueCustomerId and AssetTypeId = @AssetTypeId --and ([hash]=@oldassignHash or [hash] is null)

		declare @IssuedCNYBalance decimal(20,8), @IssuedBTCBalance decimal(20,8), @RedeemedCNYBalance decimal(20,8), 
		@RedeemedBTCBalance decimal(20,8), @voucherTransactionId int

		if exists(select VoucherId from Voucher with (nolock) where VoucherId = @voucherId and IsRedeemed = 1)
		begin
			select @IssuedCNYBalance = Balance from AssetBalance with (nolock) where CustomerId = @IssueCustomerId and AssetTypeId = 1
			select @IssuedBTCBalance = Balance from AssetBalance with (nolock) where CustomerId = @IssueCustomerId and (AssetTypeId = case isNull(@AssetTypeId,-1) when -1 then AssetTypeId else @AssetTypeId end )
			select @RedeemedCNYBalance = Balance from AssetBalance with (nolock) where CustomerId = @RedeemCustomerId and AssetTypeId = 1
			select @RedeemedBTCBalance = Balance from AssetBalance with (nolock) where CustomerId = @RedeemCustomerId and (AssetTypeId = case isNull(@AssetTypeId,-1) when -1 then AssetTypeId else @AssetTypeId end )

			select @voucherTransactionId = TransactionId from Voucher where VoucherId = @voucherId

			insert into AdvancedTransactionV1([TransactionId], [TransactionTypeId], [A_OfferBalanceAfterTransaction], [A_WantBalanceAfterTransaction], [B_OfferBalanceAfterTransaction], [B_WantBalanceAfterTransaction])
			values(@voucherTransactionId, 4, @IssuedCNYBalance, @IssuedBTCBalance, @RedeemedCNYBalance, @RedeemedBTCBalance)
			declare @NewAdvancedTransactionId int =SCOPE_IDENTITY()
			select AdvanceTransactionId,TransactionId,A_OfferBalanceAfterTransaction,A_WantBalanceAfterTransaction,B_OfferBalanceAfterTransaction,B_WantBalanceAfterTransaction 
				from AdvancedTransactionV1 where AdvanceTransactionId=@NewAdvancedTransactionId
		end
	end
	else
	begin
		RAISERROR('No Matched AssetInfo',12,1)
	end
	commit tran     
end try
begin catch 
	print('rollback')
	rollback tran
	Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
		select Getdate(),@RedeemCustomerId,@IssueCustomerId,'[usp_RedeemVoucherAsset]',ERROR_MESSAGE()
	select -1
	throw
end catch
END