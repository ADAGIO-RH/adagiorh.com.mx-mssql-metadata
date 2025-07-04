USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-06-17
-- Description:	sp para buscar los tipos de Datos
-- App.spBuscarTiposDatos @TipoDato='var'
-- =============================================
CREATE PROCEDURE App.spBuscarTiposDatos
	(
		@TipoDato varchar(255) = ''
	)
AS
BEGIN

		SELECT
			TipoDato, 
			isnull(Primario, '') Primario, 
			isnull(Descripcion,'') Descripcion
		FROM
			App.tblCatTiposDatos 
		where 
			TipoDato like '%'+@TipoDato+'%' or @TipoDato = '' or @TipoDato is null
		order by TipoDato
	
END
GO
