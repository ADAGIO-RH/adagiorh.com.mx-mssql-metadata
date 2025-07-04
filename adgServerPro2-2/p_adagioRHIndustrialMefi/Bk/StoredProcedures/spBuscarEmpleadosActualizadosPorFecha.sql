USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Bk].[spBuscarEmpleadosActualizadosPorFecha](
    @Fecha date
)as 
    if object_id('tempdb..#TempEmpleados') is not null
	   drop table #TempEmpleados;

    select DISTINCT IDEmpleado
    INTO #TempEmpleados
    from [Bk].[TblEmpleadoActualizado]
    where cast(FechaHora as Date) = @Fecha

    select e.*
    from #TempEmpleados t
	   join RH.tblEmpleadosMaster e on t.IDEmpleado = e.IDEmpleado
GO
