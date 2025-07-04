USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Demo].[spCerrarPeriodosAnteriores] as

	declare @IDPeriodo int
		,@Fecha date = getdate()
		,@Ejercicio int = datepart(year, getdate()) 
		,@IDUsuarioAdmin int
		,@IDTipoNomina int
		,@dtFiltros Nomina.dtFiltrosRH
	;

	select @IDUsuarioAdmin = cast(Valor as int)
	from  App.tblConfiguracionesGenerales
	where [IDConfiguracion] ='IDUsuarioAdmin'

	if object_id('tempdb..#tempPeriodosACalcularYCerrar') is not null drop table #tempPeriodosACalcularYCerrar;

	select *
	INTO #tempPeriodosACalcularYCerrar
	from Nomina.tblCatPeriodos
	where Ejercicio = @Ejercicio 
		and FechaFinPago < @Fecha
		and isnull(Cerrado,0) = 0

	select @IDPeriodo = min(IDPeriodo) from #tempPeriodosACalcularYCerrar

	while exists(select top 1 1 
				from #tempPeriodosACalcularYCerrar
				where IDPeriodo >= @IDPeriodo)
	begin
		print @IDPeriodo

		select @IDTipoNomina = IDTipoNomina
		from #tempPeriodosACalcularYCerrar
		where IDPeriodo = @IDPeriodo

		begin try
			exec [Nomina].[spCalculoNomina] 
			   @IDUsuario = @IDUsuarioAdmin
			  ,@IDTipoNomina = @IDTipoNomina
			  ,@IDPeriodo = @IDPeriodo
			  ,@dtFiltros = @dtFiltros
			  ,@isPreviewFiniquito = 0
			  ,@ExcluirBajas = 1
			  ,@AjustaISRMensual = 1

			exec[Nomina].[spCerrarPeriodoNomina] 
			   @IDPeriodo = @IDPeriodo
			  ,@Value = 1
		end try
		begin catch
			exec Demo.spGetErrorInfo 
		end catch

		select @IDPeriodo = min(IDPeriodo) from #tempPeriodosACalcularYCerrar where IDPeriodo > @IDPeriodo
	end;
GO
