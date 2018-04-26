use blurbdb
GO
CREATE PROCEDURE usp_GetCategoryByProductId
(
	@productId int
)
AS
BEGIN
	SELECT CategoryId,
		CategoryName,
		ParentCategoryId,
		ProductId,
		DisplayOrder,
		InsertDate,
		SaveDate,
		UpdateDate
	FROM Category 
	WHERE ProductId = @productId
END