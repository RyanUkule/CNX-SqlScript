CREATE PROCEDURE usp_GetRewardInterestSettingByAssetTypeId
(
	@assetTypeId int
)
AS
BEGIN
	SELECT [RewardInterestSettingId]
		  ,[AssetTypeId]
		  ,[Rate]
		  ,[IntervalMinute]
		  ,[RunningTime]
		  ,[CreateDate]
		  ,[LastRunningTime]
		  ,[Active]
		  ,[CalculateInterval]
	  FROM [cnx].[dbo].[RewardInterestSetting]
	  WHERE AssetTypeId = @assetTypeId
END