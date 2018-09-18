USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAtiveCampaigns]    Script Date: 2018/09/18 11:22:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetAtiveCampaigns]
AS
BEGIN
	SELECT  [CampaignId]
      ,[CampaignName]
      ,[StartDate]
      ,[EndDate]
      ,[Description]
      ,[RewardAssetTypeId]
      ,[RewardAmount]
	  ,[Description]
      ,[Active]
  FROM [cnx].[dbo].[Campaign] with(nolock)
  where Active = 1
END
