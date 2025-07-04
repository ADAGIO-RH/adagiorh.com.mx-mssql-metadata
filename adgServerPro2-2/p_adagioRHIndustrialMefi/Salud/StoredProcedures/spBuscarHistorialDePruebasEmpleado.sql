USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Salud].[spBuscarHistorialDePruebasEmpleado](
	@IDEmpleado int,
	@IDUsuario int
) as

	select 
		pe.IDPruebaEmpleado
		,pe.IDPrueba
		,p.Nombre as Prueba
		,c.IDCuestionario
		,c.Nombre as Cuestionario
		,ce.IDCuestionarioEmpleado
		,ce.FechaCreacion
		,CAST(ce.FechaCreacion as Date) as Fecha
		,isnull(ce.Resultado,'SIN RESULTADO') as Resultado
	from Salud.tblPruebasEmpleados pe with (nolock)
		join Salud.tblPruebas p with (nolock) on p.IDPrueba = pe.IDPrueba
		join Salud.tblCuestionariosEmpleados ce with (nolock) on pe.IDPruebaEmpleado = ce.IDPruebaEmpleado
		join Salud.tblCuestionarios c with (nolock) on c.IDReferencia = ce.IDCuestionarioEmpleado and c.TipoReferencia = 2
	where pe.IDEmpleado = @IDEmpleado
GO
