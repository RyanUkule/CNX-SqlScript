USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetRewardInterestSetting]    Script Date: 2020/1/13 18:32:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_GetRewardInterestSetting]
AS
BEGIN
SELECT  [RewardInterestSettingId]
      ,[AssetTypeId]
      ,[Rate]
      ,[IntervalMinute]
      ,[RunningTime]
      ,[CreateDate]
      ,[UpdateDate]
      ,[Active]
      ,[RewardIntervalMinute]
      ,[RewardAssetTypeId]
	  ,[MinBalance]
	  ,[MaxBalance]
	  ,[Name]
	  ,[Description]
	  ,ReferInterestSettingId
	  ,RewardIntervalUnit
  FROM [cnx].[dbo].[RewardInterestSetting] with(nolock)
  where Active = 1
END