USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarSalasCapacitacion]
(
	@IDSalaCapacitacion int = 0
)
AS
BEGIN
	
	SELECT 
		IDSalaCapacitacion
		,Nombre
		,isnull(Ubicacion,'') as Ubicacion
		,isnull(Capacidad,0) as  Capacidad
		,ROW_NUMBER() OVER(Order by IDSalaCapacitacion asc) as ROWNUMBER
	FROM STPS.tblSalasCapacitacion with (nolock)
	where (IDSalaCapacitacion = @IDSalaCapacitacion) OR (ISNULL(@IDSalaCapacitacion,0) = 0)

END
GO
