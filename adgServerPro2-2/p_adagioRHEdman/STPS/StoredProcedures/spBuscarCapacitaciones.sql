USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarCapacitaciones]
(
	@IDCapacitacion int = null
)
AS
BEGIN

		select 
		IDCapacitaciones
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatCapacitaciones]
		where IDCapacitaciones = @IDCapacitacion or @IDCapacitacion is null
END
GO
