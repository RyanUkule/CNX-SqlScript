use CNX
GO
CREATE PROCEDURE usp_InsertBalanceHistoryOfEachDay
(
	@assetTypeId int,
	@rewardInterestSettingId int
)
AS
BEGIN
	INSERT INTO BalanceHistoryOfEachDay (RewardInterestSettingId, CustomerId, AssetTypeId, Balance, Date) --VALUES(@customerId, @assetTypeId, @balance, GETDATE())
	SELECT @rewardInterestSettingId, a.CustomerId, AssetTypeId, Balance, GETDATE() 
	FROM AssetBalance a
	inner join customer c with(nolock) on a.CustomerId = c.CustomerId
	WHERE AssetTypeId = @assetTypeId
		and a.CustomerId <> 2
		--and c.IsTestAccount = 0
END