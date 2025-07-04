USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc Salud.spBuscarCuestionariosEmpleados(
	@IDPrueba int,
	@IDUsuario int
) as
	select
		 pe.IDPruebaEmpleado
		,pe.IDPrueba
		,pe.IDEmpleado
		,ce.IDCuestionarioEmpleado
		,c.Nombre as Cuestionario
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Nombre
		,format(ISNULL(ce.FechaCreacion, GETDATE()), 'dd/MM/yyyy HH:mm') as FechaStr
	from Salud.tblPruebasEmpleados pe with (nolock)
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu on dfeu.IDEmpleado = pe.IDEmpleado and dfeu.IDUsuario = @IDUsuario
		join Salud.tblCuestionariosEmpleados ce with (nolock) on pe.IDPruebaEmpleado = ce.IDPruebaEmpleado
		join Salud.tblCuestionarios c with (nolock) on c.IDReferencia = ce.IDCuestionarioEmpleado and c.TipoReferencia = 2
		join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = pe.IDEmpleado
	where pe.IDPrueba = @IDPrueba
	order by ce.FechaCreacion desc
GO
