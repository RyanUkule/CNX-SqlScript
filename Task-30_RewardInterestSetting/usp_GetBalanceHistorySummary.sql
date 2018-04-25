use CNX
GO
CREATE PROCEDURE usp_GetBalanceHistorySummary
(
	@rewardInterestSettingId int
)
AS
BEGIN
	SELECT CustomerId, sum(Balance) SumBalance, count(*) Count
	FROM BalanceHistoryOfEachDay 
	WHERE RewardInterestSettingId = @rewardInterestSettingId
	GROUP BY CustomerId
END