USE cnx
GO
CREATE TABLE tb_MirrorData
(
	CustomerId int,
	Balance decimal(38,8),
	VoucherId varchar(30)
)
GO
IF(OBJECT_ID('usp_AddBTGAssetBalance') is not null)
	DROP PROC usp_AddBTGAssetBalance
GO
CREATE PROC usp_AddBTGAssetBalance
AS
BEGIN
	DECLARE @customerId int
	DECLARE	@balance decimal(38,8)
	DECLARE @voucherId varchar(30)

	DECLARE balance_cursor CURSOR FOR
	SELECT CustomerId, Balance, VoucherId FROM tb_MirrorData
	OPEN balance_cursor  

	FETCH NEXT FROM balance_cursor INTO @customerId , @balance, @voucherId
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		BEGIN TRY
			BEGIN TRAN

				IF(EXISTS(SELECT * FROM Customer WHERE CustomerId = @customerId))
				BEGIN
					IF(@balance = 0)
					BEGIN
						PRINT 'CustomerId:' + CONVERT(VARCHAR(MAX),@customerId) + ' Balance = 0'
						CONTINUE
					END

					--更新AssetBalance
					UPDATE AssetBalance SET Balance = Balance + @balance,UpdateDate = GETDATE()
					WHERE customerId = @customerId and AssetTypeId = 13

					--插入Voucher
					INSERT INTO Voucher(VoucherId, RedemptionCodeHash, Value, IssuedByCustomerId, IsRedeemed, RedeemedByCustomerId, 
						IsCanceled, AssetTypeId, UpdateDate, InsertDate, SaveDate, Note, CampaignId)
					VALUES (@voucherId, '', @balance, 2, 1, @customerId, 
						0, 13, GETDATE(), GETDATE(), GETDATE(),N'BTC分叉BTG', 0)

					--Redeem Voucher
					INSERT INTO AdvancedTransaction([VoucherId], [TransactionType], [A_CNYBalance], [A_Balance], [B_CNYBalance], [B_Balance])
					VALUES (@voucherId, 'Voucher', 0, 0, 0, @balance)

				END
				ELSE
				BEGIN
					PRINT 'CustomerId:' + CONVERT(VARCHAR(MAX), @customerId) + ' not exist'
				END

			COMMIT TRAN
		END TRY
		BEGIN CATCH
			PRINT ERROR_MESSAGE()
			PRINT 'CustomerId:' + convert(varchar(max), @customerId) + ' Balance:' + convert(varchar(max), @balance) + ' VoucherId:' + @voucherId
		END CATCH

		FETCH NEXT FROM balance_cursor INTO @customerId , @balance, @voucherId
	END

	CLOSE balance_cursor
	DEALLOCATE balance_cursor
END