USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarOcupaciones]
(
	@IDOcupaciones int = null
)
AS
BEGIN

		select 
			IDOcupaciones
			,UPPER(Codigo) as Codigo
			,UPPER(Codigo) +' - '+ UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatOcupaciones]
		where IDOcupaciones = @IDOcupaciones or @IDOcupaciones is null

END
GO
