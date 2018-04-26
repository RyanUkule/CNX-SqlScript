use blurbdb
GO
CREATE PROCEDURE usp_GetBlurbByBlurbId
(
	@blurbId int
)
AS
BEGIN
	SELECT 
		b.BlurbId,
		b.CategoryId,
		c.CategoryName,
		b.[Description],
		b.DefaultText,
		t.[Text] as TranslationText,
		b.InsertDate
	FROM Blurb b
	INNER JOIN Category c on b.categoryId = c.CategoryId
	INNER JOIN translation t on t.BlurbId = b.BlurbId
	WHERE b.BlurbId = @blurbId
END