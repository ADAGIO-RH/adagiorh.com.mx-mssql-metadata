USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarPuestoEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		
		Select 
		     PE.IDPuestoEmpleado,
			PE.IDEmpleado,
			PE.IDPuesto,
			P.Codigo,
			JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion,
			PE.FechaIni,
			PE.FechaFin
		From RH.tblPuestoEmpleado PE
			Inner join RH.tblCatPuestos P
				on PE.IDPuesto = P.IDPuesto
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc

END
GO
