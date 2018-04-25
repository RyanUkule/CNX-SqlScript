CREATE PROC usp_UpdateRewardInterestSettingLastRunningTime
(
	@assetTypeId int,
	@lastRunningTime datetime
)
AS
BEGIN
	UPDATE RewardInterestSetting set LastRunningTime = @lastRunningTime WHERE AssetTypeId = @assetTypeId
END