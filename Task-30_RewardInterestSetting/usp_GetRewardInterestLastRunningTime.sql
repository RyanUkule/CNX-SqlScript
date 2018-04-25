use CNX
GO
CREATE PROCEDURE usp_GetRewardInterestLastRunningTime
(
	@RewardInterestSettingId int
)
AS
BEGIN
	SELECT TOP 1 LastRunningTime FROM RewardInterestHistory
		WHERE RewardInterestSettingId = @RewardInterestSettingId
		ORDER BY LastRunningTime DESC
END