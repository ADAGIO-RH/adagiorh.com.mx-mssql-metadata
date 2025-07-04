USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc Reportes.spReporteFichaMedicaColaborador(
	@ClaveEmpleadoInicial varchar(20),
	@IDUsuario int 
) as
	select 
		e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,IDSaludEmpleado
		,se.TipoSangre
		,isnull(se.Estatura,0) as Estatura
		,isnull(se.Peso	   ,0) as Peso
		,isnull(se.IMC	   ,0) as IMC
		,se.Alergias
		,se.IMCC
		,se.TratamientoAlergias
		,RequiereTarjetaSalud = case when isnull(se.RequiereTarjetaSalud,0) = 1 then 'SI' else 'NO' end
		,se.VencimientoTarjeta
	from [RH].[tblEmpleadosMaster] e with (nolock)
		join [RH].[tblSaludEmpleado] se with (nolock) on se.IDEmpleado = e.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu with (nolock) on dfeu.IDEmpleado = e.IDEmpleado and dfeu.IDUsuario = @IDUsuario
	where e.ClaveEmpleado = @ClaveEmpleadoInicial
GO
