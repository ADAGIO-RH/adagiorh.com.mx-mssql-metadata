USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBuscarTiposNotificaciones]
(
    @IDTipoNotificacion	VARCHAR(50) = NULL
	, @IsSpecial INT = NULL
) AS
	
	BEGIN

		DECLARE @SI BIT = 1;

		SELECT IDTipoNotificacion
				, Descripcion
				, Asunto
				, Nombre
				, COALESCE(IsSpecial, 0) AS [IsSpecial]
		FROM [App].[tblTiposNotificaciones]
		WHERE (IDTipoNotificacion = @IDTipoNotificacion OR @IDTipoNotificacion IS NULL OR @IDTipoNotificacion = '')
				AND (IsSpecial = @IsSpecial OR @IsSpecial IS NULL)
				AND IsActivo = @SI

	END
GO
