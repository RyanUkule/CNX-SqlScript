use blurbdb
GO
CREATE PROCEDURE usp_GetBlurbByText
(
	@text nvarchar(max)
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
	FROM blurb b
	INNER JOIN Category c on b.categoryId = c.CategoryId
	INNER JOIN translation t on t.BlurbId = b.BlurbId
	WHERE b.DefaultText like '%' + @text + '%' or t.Text like '%' + @text + '%'
END