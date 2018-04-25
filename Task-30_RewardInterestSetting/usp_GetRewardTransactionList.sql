use CNX
GO
CREATE PROCEDURE usp_GetRewardTransactionList
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
		ROW_NUMBER() over(order by RewardTransactionId) Id,
		[RewardTransactionId],
		[RewardInterestSettingId],
		r.[CustomerId],
		c.[UserName] as CustomerName,
		[RewardTypeId],
		[AssetTypeId],
		[Comment],
		[BaseBalance],
		[Rate],
		[Amount],
		[RewardDate]
	INTO #tmpTransaction
	FROM RewardTransaction r with (nolock)
	INNER JOIN Customer c on r.CustomerId = c.CustomerId
	WHERE AssetTypeId = case when @assetTypeId is null then AssetTypeId else @assetTypeId end
		and RewardDate >= CASE when @beginDate is null then RewardDate else @beginDate end
		and RewardDate <= CASE WHEN @endDate is null THEN RewardDate else @endDate end

	SELECT 
		[RewardTransactionId],
		[RewardInterestSettingId],
		[CustomerId],
		[CustomerName],
		[RewardTypeId],
		[AssetTypeId],
		[Comment],
		[BaseBalance],
		[Rate],
		[Amount],
		[RewardDate]
	FROM #tmpTransaction
	WHERE Id >= (@pageIndex - 1) * @pageSize + 1 AND Id <= @pageIndex * @pageSize
	
	SELECT COUNT(*) FROM #tmpTransaction
END