use blurbdb
GO
CREATE PROCEDURE usp_UpdateBlurb
(
	@blurbId int,
	@defaultText varchar(max),
	@text nvarchar(max)
)
AS
BEGIN
	UPDATE blurb set DefaultText = @defaultText WHERE blurbId = @blurbId

	UPDATE translation set [Text] = @text WHERE blurbId = @blurbId
END