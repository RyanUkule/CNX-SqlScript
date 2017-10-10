USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_RedeemVoucherAsset]    Script Date: 2017/09/22 16:39:31 ******/
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
	declare @A_Hash nvarchar(500), @B_Hash nvarchar(500) 

	select @A_Hash = [Hash] from AssetBalance 
	where customerId = @RedeemCustomerId and AssetTypeId = @AssetTypeId --and ([hash]=@oldredeemHash or [hash] is null)
	select @B_Hash = [Hash] from AssetBalance 
	where customerId = @IssueCustomerId and AssetTypeId = @AssetTypeId --and ([hash]=@oldassignHash or [hash] is null)
	if(@A_Hash is not null and @B_Hash is not null)
	begin
		Update AssetBalance set Balance = Balance + @value,UpdateDate = @updateDate, [Hash] = @redeemHash
		where customerId = @RedeemCustomerId and AssetTypeId = @AssetTypeId --and ([hash]=@oldredeemHash or [hash] is null)

		Update AssetBalance set Balance =  Balance - @value , FrozenBalance = FrozenBalance - @value, updateDate = @updateDate, [hash] = @assignHash
		where customerId = @IssueCustomerId and AssetTypeId = @AssetTypeId --and ([hash]=@oldassignHash or [hash] is null)

		declare @IssuedCNYBalance decimal(20,8), @IssuedBTCBalance decimal(20,8), @RedeemedCNYBalance decimal(20,8), 
		@RedeemedBTCBalance decimal(20,8)

		if exists(select VoucherId from Voucher with (nolock) where VoucherId = @voucherId and IsRedeemed = 1)
		begin
		print 'test1'
			select @IssuedCNYBalance = Balance from AssetBalance with (nolock) where CustomerId = @IssueCustomerId and AssetTypeId = 11
			select @IssuedBTCBalance = Balance from AssetBalance with (nolock) where CustomerId = @IssueCustomerId and (AssetTypeId = case isNull(@AssetTypeId,-1) when -1 then AssetTypeId else @AssetTypeId end )
			select @RedeemedCNYBalance = Balance from AssetBalance with (nolock) where CustomerId = @RedeemCustomerId and AssetTypeId = 11
			select @RedeemedBTCBalance = Balance from AssetBalance with (nolock) where CustomerId = @RedeemCustomerId and (AssetTypeId = case isNull(@AssetTypeId,-1) when -1 then AssetTypeId else @AssetTypeId end )

			insert into AdvancedTransaction([VoucherId], [TransactionType], [A_CNYBalance], [A_Balance], [B_CNYBalance], [B_Balance])
			values(@voucherId, 'Voucher', @IssuedCNYBalance, @IssuedBTCBalance, @RedeemedCNYBalance, @RedeemedBTCBalance)
			declare @NewAdvancedTransactionId int =SCOPE_IDENTITY()
			select AdvanceTransactionId,VoucherId,A_CNYBalance,A_Balance,B_CNYBalance,B_Balance from AdvancedTransaction where AdvanceTransactionId=@NewAdvancedTransactionId
		end
	end
	else
	begin
		RAISERROR('No Matched AssetInfo',12,1)
	end
	commit tran     
end try
begin catch 
	PRINT ERROR_MESSAGE()
	print('rollback')
	rollback tran
	Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
		select Getdate(),@RedeemCustomerId,@IssueCustomerId,'[usp_RedeemVoucherAsset]',ERROR_MESSAGE()
	select -1
	throw
end catch
END
