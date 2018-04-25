use CNX
GO
CREATE PROCEDURE usp_DeleteBalanceHistoryOfEachDay
(
	@rewardInterestSettingId int
)
AS
BEGIN
	DELETE FROM BalanceHistoryOfEachDay WHERE RewardInterestSettingId = @rewardInterestSettingId
		
END
