USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Norma35].[spBuscarEncuestasEmpleados] --@IDEncuesta= 3, @IDUsuario = 1
(
	@IDEncuestaEmpleado int = 0,
	@IDEmpleado int = 0,
	@IDEncuesta int = 0,
	@PageNumber int = 1,  
	@PageSize int = 2147483647,  
	@IDUsuario int
) as
	declare @TotalPaginas int = 0;  
  
	if (@PageNumber = 0) set @PageNumber = 1;  
	if (@PageSize = 0) set @PageSize = 2147483647;  
  
	if OBJECT_ID('tempdb..#tempEncEmpleado') is not null drop table #tempEncEmpleado;  
  
	select
		 ee.IDEncuestaEmpleado
		,ee.IDEncuesta
		,ee.IDCatEstatus
		,estatus.Descripcion as Estatus
		,isnull(ee.FechaAsignacion, getdate()) FechaAsignacion
		,isnull(ee.FechaUltimaActualizacion, getdate()) FechaUltimaActualizacion

		,e.NombreEncuesta
		,isnull(e.FechaIni,'1990-01-01') as FechaIni
		,isnull(e.FechaFin,'1990-01-01') as FechaFin

		,ce.IDCatEncuesta
		,ce.Nombre as NombreCatEncuesta
		,ce.Descripcion as DescripcionCatEncuesta
		,isnull(ee.TotalPreguntas, 0) TotalPreguntas
		,isnull(ee.TotalPreguntasContestadas, 0) TotalPreguntasContestadas
		,isnull(ee.IDEmpleado,0) IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
		,M.Departamento as Departamento
		,M.Puesto as Puesto
		,isnull(ee.Resultado,'--') as Resultado
		,ISNULL(ee.RequiereAtencion,'') as RequiereAtencion
	INTO #tempEncEmpleado
	from [Norma35].[tblEncuestasEmpleados] ee with (nolock)
		join [Norma35].[tblEncuestas] e with (nolock) on e.IDEncuesta = ee.IDEncuesta
		join [Norma35].[tblCatEncuestas] ce with (nolock) on ce.IDCatEncuesta = e.IDCatEncuesta
		join [Norma35].[tblCatEstatus] estatus with (nolock) on estatus.IDCatEstatus = ee.IDCatEstatus
		join [RH].[tblEmpleadosMaster] M with (nolock) on ee.IDEmpleado = M.IDEmpleado
	where (ee.IDEncuestaEmpleado = @IDEncuestaEmpleado or @IDEncuestaEmpleado = 0) and 
		(ee.IDEmpleado = @IDEmpleado or @IDEmpleado = 0) and 
		(ee.IDEncuesta = @IDEncuesta or @IDEncuesta = 0)

	select @TotalPaginas =CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))  
	from #tempEncEmpleado  
  
	select *  
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end  
	from #tempEncEmpleado  
	order by IDEncuestaEmpleado desc  
	OFFSET @PageSize * (@PageNumber - 1) ROWS  
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
