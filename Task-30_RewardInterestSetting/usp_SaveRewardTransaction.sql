CREATE PROCEDURE [dbo].[usp_SaveRewardTransaction]
(
	@rewardInterestSettingId int = NULL,
	@customerId int,
	@rewardTypeId int,
	@assetTypeId int,
	@comment nvarchar(500),
	@baseBalance decimal(38, 8),
	@rate decimal(38, 8) = null,
	@amount decimal(38, 8),
	@rewardDate datetime
)
AS
BEGIN
	BEGIN TRAN
		DECLARE @newTransactionId int
		DECLARE @newBalance decimal(38,8)

		INSERT INTO RewardTransaction VALUES (@rewardInterestSettingId, @customerId, @rewardTypeId, @assetTypeId, @comment, @baseBalance, @rate, @amount, @rewardDate)
		SELECT @newTransactionId = @@IDENTITY

		SELECT @newBalance = Balance + @amount FROM AssetBalance WHERE CustomerId = @customerId AND AssetTypeId = @assetTypeId

		INSERT INTO AdvancedTransactionV1(TransactionId, TransactionTypeId, TransactionNote, A_OfferBalanceAfterTransaction, B_OfferBalanceAfterTransaction, A_WantBalanceAfterTransaction, B_WantBalanceAfterTransaction, Hash) 
			VALUES(@newTransactionId, 5, null, @amount, 0, 0, @newBalance, null)

		UPDATE AssetBalance SET Balance = Balance + @amount WHERE CustomerId = @customerId AND AssetTypeId = @assetTypeId

	COMMIT
END