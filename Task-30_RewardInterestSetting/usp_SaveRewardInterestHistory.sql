use CNX
GO
CREATE PROCEDURE usp_SaveRewardInterestHistory
(
  @RewardInterestSettingId int,
  @Rate decimal(38, 8),
  @TotalCustomerCount int,
  @TotalBaseBalance decimal(38, 8),
  @TotalInterest decimal(38, 8),
  @LastRunningTime datetime
)
AS
BEGIN
	INSERT INTO RewardInterestHistory VALUES (@RewardInterestSettingId, @Rate, @TotalCustomerCount, @TotalBaseBalance, @TotalInterest, @LastRunningTime)
END