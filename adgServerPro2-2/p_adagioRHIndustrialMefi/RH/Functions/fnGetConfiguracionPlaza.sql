USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function RH.fnGetConfiguracionPlaza(
 @Config Varchar(max),
 @configuracion Varchar(50)
)
RETURNS @configTabla TABLE(
	IDTipoConfiguracionPlaza VARCHAR(max),
	Valor VARCHAR(max),
	Descripcion VARCHAR(max)
)
AS
BEGIN
	INSERT INTO @configTabla
	SELECT [Value].IDTipoConfiguracionPlaza,
			[Value].Valor,
			[Value].Descripcion
	FROM OPENJSON (@config) AS [Key]
	CROSS APPLY OPENJSON([Key].value)
		WITH (
			IDTipoConfiguracionPlaza VARCHAR(max) '$.IDTipoConfiguracionPlaza',
			Valor VARCHAR(max) '$.Valor',
			Descripcion VARCHAR(max) '$.Descripcion'
		) AS [Value]
	where [Value].[IDTipoConfiguracionPlaza] = @configuracion

	RETURN;
END;
GO
