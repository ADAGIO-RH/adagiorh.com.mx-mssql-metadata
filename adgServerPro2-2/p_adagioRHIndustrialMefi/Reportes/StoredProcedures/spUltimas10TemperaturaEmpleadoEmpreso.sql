USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Reportes].[spUltimas10TemperaturaEmpleadoEmpreso](
	@ClaveEmpleadoInicial varchar(20) 
	,@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	select top 10
		format(te.FechaHora,'dd/MM/yyyy HH:mm') as Fecha
		,cast(te.Temperatura as varchar(10))+'°' as Temperatura
	from Salud.tblTemperaturaEmpleado te with (nolock)
		join RH.tblEmpleadosMaster e on e.IDEmpleado = te.IDEmpleado
	where e.ClaveEmpleado = @ClaveEmpleadoInicial
	order by te.FechaHora desc
GO
