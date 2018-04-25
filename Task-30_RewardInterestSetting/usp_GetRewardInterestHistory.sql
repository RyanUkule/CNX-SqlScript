use CNX
GO
CREATE PROCEDURE usp_GetRewardInterestHistory
(
	@assetTypeId int = null,
	@beginDate datetime = null,
	@endDate datetime = null,
	@pageIndex int,
	@pageSize int
)
AS
BEGIN
	SELECT 
		ROW_NUMBER() OVER(order by Id) AS rowId,
		Id,
		r.RewardInterestSettingId,
		s.AssetTypeId,
		r.Rate,
		TotalCustomerCount,
		TotalBaseBalance,
		TotalInterest,
		LastRunningTime
	INTO #tmpHistory
	FROM RewardInterestHistory r with (nolock)
	INNER JOIN RewardInterestSetting s on r.RewardInterestSettingId = s.RewardInterestSettingId
	WHERE s.AssetTypeId = case when @assetTypeId is null then AssetTypeId else @assetTypeId end
		and LastRunningTime >= CASE when @beginDate is null then LastRunningTime else @beginDate end
		and LastRunningTime <= CASE WHEN @endDate is null THEN LastRunningTime else @endDate end

	SELECT
		Id,
		RewardInterestSettingId,
		AssetTypeId,
		Rate,
		TotalCustomerCount,
		TotalBaseBalance,
		TotalInterest,
		LastRunningTime
	FROM #tmpHistory
	WHERE rowId >= (@pageIndex - 1) * @pageSize + 1 AND rowId <= @pageIndex * @pageSize
	
	SELECT COUNT(*) FROM #tmpHistory
END