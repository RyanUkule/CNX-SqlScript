use cnx
GO
CREATE PROCEDURE usp_GetRewardInterestSetting
AS
BEGIN
	SELECT [RewardInterestSettingId]
		  ,[AssetTypeId]
		  ,[Rate]
		  ,[IntervalMinute]
		  ,[RunningTime]
		  ,[CreateDate]
		  ,[Active]
		  ,[UpdateDate]
		  ,[CalculateInterval]
	  FROM [cnx].[dbo].[RewardInterestSetting]
END