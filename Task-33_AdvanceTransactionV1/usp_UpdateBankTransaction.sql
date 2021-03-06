USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateBankTransaction]    Script Date: 2018/03/30 14:59:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_UpdateBankTransaction]
@customerId int,
@bankTransactionId int,
@transactionName nvarchar(50),
@accountNumber nvarchar(250),
@amount decimal(20,8),
@depositCode nvarchar(50),
@linkRequestId int,
@statusId int
AS
BEGIN
begin tran
begin try
	declare @requestAmount decimal(20,8), @difference decimal(20,8), @customerRole int, @requestStatus int, @result nvarchar(50),@AdvanceTransactionId int 
	if(@linkRequestId is not null)
	begin
		select @requestAmount = Amount, @requestStatus = RequestStatusId from TransferRequest with (nolock) where RequestId = @linkRequestId
		set @difference = @amount - @requestAmount
		print @difference
		if(@difference > 1 or @difference < -1)
		begin
			set @linkRequestId = null
			set @result = 'Amount'
		end

		select @customerRole = RoleId from webpages_UsersInRoles U with (nolock)
		where U.UserId = @customerId

		if(@customerRole = 3 and @requestStatus not in (2, 6, 9))
		begin
			set @linkRequestId = null
			set @result = 'Role'
		end
		if(@customerRole = 4 and @requestStatus not in (2, 6, 8, 9) )
		begin
			set @linkRequestId = null
			set @result = 'Role'
		end
		if(@customerRole = 6 and @requestStatus not in (2, 6, 8, 9))
		begin
			set @linkRequestId = null
			set @result = 'Role'
		end
		print 0
		print @linkRequestId
	end

	update BankTransaction 
	set
	[TransactionName] = case when @transactionName is null then [TransactionName] else @transactionName end,
	[TransactionAccountNumber] = case when @accountNumber is null then [TransactionAccountNumber] else @accountNumber end,
	[TransactionAmount] = case when (@amount is null or @amount = 0) then [TransactionAmount] else @amount end,
	[DepositeCode] = case when @depositCode is null then [DepositeCode] else @depositCode end,
	[LinkRequestId] = case when @linkRequestId is null then [LinkRequestId] else @linkRequestId end,
	[TransactionStatusId] = case when @statusId is null or (@statusId = 2 and @linkRequestId is null) then [TransactionStatusId] else @statusId end,
	[UpdateBy] = @customerId,
	[UpdateDate] = getdate()
	where 
	BankTransactionId = @bankTransactionId

	if(@linkRequestId is not null and @bankTransactionId is not null)
	begin
		update TransferRequest set BankTransactionId = @bankTransactionId, RequestStatusId = 3, UpdateDate = getdate(), ApprovedCustomerId = @customerId
		--Amount = @amount, 
		where RequestId = @linkRequestId and BankTransactionId is null

		declare @transactionTypeId int, @realAmount decimal(20,8), @CNYBalance decimal(20,8), @BTCBalance decimal(20,8),
				@RequestTypeId int, @Commision decimal(20,8), @AssetTypeId int

		select @RequestTypeId = RequestTypeId, @Commision = Commision, @AssetTypeId = AssetTypeId
		from TransferRequest with (nolock) where RequestId = @linkRequestId
		select @transactionTypeId = (case when Name like '%Deposit%'
											then 3
											else 2
									 end)
		from [RequestType_lkp] with (nolock) where [RequestTypeId] = @RequestTypeId

		if(@RequestTypeId in (1, 5, 8, 10))
		begin
			select @CNYBalance = Balance + @Amount + @Commision from AssetBalance with (nolock) 
			where CustomerId = @CustomerId and AssetTypeId = @AssetTypeId
		end
		if(@RequestTypeId in (2, 3, 9, 11))
		begin
			select @CNYBalance = Balance - @Amount - @Commision from AssetBalance with (nolock) 
			where CustomerId = @CustomerId and AssetTypeId = @AssetTypeId
		end

		if(@CNYBalance is not null )
		begin
			insert into AdvancedTransactionV1([TransactionId], [TransactionTypeId], [A_OfferBalanceAfterTransaction], [A_WantBalanceAfterTransaction], [B_OfferBalanceAfterTransaction], [B_WantBalanceAfterTransaction])
			values(@linkRequestId, @transactionTypeId, @CNYBalance, @amount, 0, 0)
			set @AdvanceTransactionId=scope_identity()
		end
		else
		begin
			set @AdvanceTransactionId=0
		end
	end

	select
		[BankTransactionId] BankTransactionId
		,[SystemBankAccountId] SystemBankAccountId
		,[TransactionID] TransactionId
		,[TransactionDate]
		,[TransactionTypeId] TransactionTypeId
		,[TransactionCategory] Category
		,[TransactionName] TransactionName
		,[TransactionBank] TransactionBank
		,[TransactionAccountNumber] AccountNumber
		,[TransactionAmount] Amount
		,[DepositeCode] DepositCode
		,[Comment] Comment
		,[LinkRequestId] LinkRequestId
		,[TransactionStatusId] TransactionStatusId
		,[CreateBy]
		,[UpdateBy]
		,[InsertDate] ReceivedDate
		,[UpdateDate] UpdateDate
	from BankTransaction with (nolock)
	where
		BankTransactionId = @bankTransactionId

	select @result
	select AdvanceTransactionId, TransactionId,A_OfferBalanceAfterTransaction,A_WantBalanceAfterTransaction,B_OfferBalanceAfterTransaction,B_WantBalanceAfterTransaction 
	from AdvancedTransactionV1 
	where AdvanceTransactionId=@AdvanceTransactionId
	commit tran
end try
begin	catch 
print('rollback')
rollback tran
select ERROR_MESSAGE()
end catch
END





