USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_DeleteBalanceHistoryOfEachDay]    Script Date: 2018/08/03 10:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_DeleteBalanceHistoryOfEachDay]
(
	@rewardInterestSettingId int = null
)
AS
BEGIN
	IF(@rewardInterestSettingId IS NOT NULL)
	BEGIN
		DELETE FROM BalanceHistoryOfEachDay WHERE RewardInterestSettingId = @rewardInterestSettingId
	END
	ELSE
	BEGIN
		DELETE FROM BalanceHistoryOfEachDay
	END	
END
