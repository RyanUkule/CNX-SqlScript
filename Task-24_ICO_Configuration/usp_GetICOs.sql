USE CNX
GO
CREATE PROCEDURE usp_GetICOs
(
	@id int = 0,
	@name varchar(50) = null,
	@startDate datetime = null,
	@endDate datetime = null
)
AS
BEGIN
	IF(@id = 0)
	BEGIN
		IF(@name IS NOT NULL)
		BEGIN
			SELECT 
				ICOId, Name, TotalValue, ConverPrice, OfferAssetTypeId, WantAssetTypeId, StartDate, EndDate, RedeemTotalAmount
			FROM ICO
			WHERE Name LIKE '%' + @name + '%' 
				  and StartDate >= case when @startDate is null then StartDate else @startDate end
				  and EndDate <= case when @endDate is null then EndDate else @endDate end
		END
		ELSE
		BEGIN
			SELECT 
				ICOId, Name, TotalValue, ConverPrice, OfferAssetTypeId, WantAssetTypeId, StartDate, EndDate, RedeemTotalAmount
			FROM ICO
			WHERE StartDate >= case when @startDate is null then StartDate else @startDate end
				  and EndDate <= case when @endDate is null then EndDate else @endDate end
		END
	END
	ELSE
	BEGIN
		SELECT 
			ICOId, Name, TotalValue, ConverPrice, OfferAssetTypeId, WantAssetTypeId, StartDate, EndDate, RedeemTotalAmount
		FROM ICO
		WHERE ICOId = @id
	END
END