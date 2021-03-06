USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateBankTransaction_V2]    Script Date: 2018/03/30 14:31:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================= 
-- Author:  Percy   
-- Email:   peng.xingxing@itr.cn        
-- Create date: 2017-3-1 10:17:34    
-- Modify date: 2017-3-1 10:17:46 
-- Description: usp_CreateBankTransaction_V2    
-- ============================================= 
ALTER PROCEDURE [dbo].[usp_CreateBankTransaction_V2]
	@customerId INT,
	@transactionId NVARCHAR(50),
	@receivedDate DATETIME,
	@typeId INT,
	@systemBankAccountId INT,
	@category NVARCHAR(50),
	@name NVARCHAR(50),
	@bank NVARCHAR(50),
	@accountNumber NVARCHAR(250),
	@amount DECIMAL(18,2),
	@depositCode NVARCHAR(50),
	@comment NVARCHAR(500),
	@linkRequestId INT,
	@statusId INT
AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		DECLARE @requestAmount DECIMAL(18, 2)
				, @difference DECIMAL(18, 2)
				, @customerRole INT
				, @requestStatus INT
				, @AdvanceTransactionId INT

		IF(@linkRequestId IS NOT NULL)
		BEGIN
			SELECT @requestAmount = Amount, @requestStatus = RequestStatusId 
			FROM TransferRequest WITH(NOLOCK) 
			WHERE RequestId = @linkRequestId

			SET @difference = @amount - @requestAmount

			IF(@difference > 1 OR @difference < -1)
			BEGIN
				SET @linkRequestId = NULL
			END

			SELECT @customerRole = RoleId 
			FROM webpages_UsersInRoles U WITH(NOLOCK)
			WHERE U.UserId = @customerId

			IF(@customerRole NOT IN (3, 4, 6) OR @requestStatus <> 9)
			BEGIN
				SET @linkRequestId = NULL
			END
		END

		IF(@linkRequestId = NULL)
		BEGIN
			SET @statusId = 1
		END

		INSERT INTO BankTransaction(
			  [TransactionID]
			  ,[TransactionDate]
			  ,[TransactionTypeId]
			  ,[SystemBankAccountId]
			  ,[TransactionCategory]
			  ,[TransactionName]
			  ,[TransactionBank]
			  ,[TransactionAccountNumber]
			  ,[TransactionAmount]
			  ,[DepositeCode]
			  ,[Comment]
			  ,[LinkRequestId]
			  ,[TransactionStatusId]
			  ,[CreateBy],[UpdateBy]
			  ,[InsertDate]
			  ,[UpdateDate])
		VALUES(@transactionId
			  ,@receivedDate
			  ,@typeId
			  ,@systemBankAccountId
			  ,@category
			  ,@name
			  ,@bank
			  ,@accountNumber
			  ,@amount
			  ,@depositCode
			  ,@comment
			  ,@linkRequestId
			  ,@statusId
			  ,@customerId
			  ,@customerId
			  ,GETDATE()
			  ,GETDATE())

		DECLARE @bankTransactionId INT = SCOPE_IDENTITY()

		IF(@linkRequestId IS NOT NULL AND @bankTransactionId IS NOT NULL)
		BEGIN
			UPDATE TransferRequest 
			SET BankTransactionId = @bankTransactionId
				, RequestStatusId = 8
				, UpdateDate = GETDATE()
				, ApprovedCustomerId = @customerId
			WHERE RequestId = @linkRequestId AND BankTransactionId IS NULL			
		END

		SELECT [BankTransactionId] BankTransactionId
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
		FROM BankTransaction WITH(NOLOCK)
		WHERE BankTransactionId = @bankTransactionId
		
	COMMIT
	END TRY
	BEGIN CATCH 
		PRINT('ROLLBACK')
		ROLLBACK TRAN
		SELECT ERROR_MESSAGE()
	END CATCH
END
