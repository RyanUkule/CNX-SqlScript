use CNX
GO
CREATE PROCEDURE usp_UpdateRewardInterestSetting
(
	@rewardInterestSettingId int,
	@assetTypeId int,
	@rate decimal(18,8),
	@intervalMinute bigint,
	@calculateInterval bigint,
	@active bit
)
AS
BEGIN
	UPDATE RewardInterestSetting 
		SET Rate = @rate
			,IntervalMinute = @intervalMinute
			,CalculateInterval = @calculateInterval
			,Active = @active
			,UpdateDate = GETDATE()
	WHERE RewardInterestSettingId = @rewardInterestSettingId
END
