USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [BK].[spReporteJorge](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as

	declare 
		@ClaveInicio varchar(20),
		@ClaveFin varchar(20)
	;

	--Select top 1 @ClaveInicio = Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	--Select top 1 @ClaveFin = Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'

	--select @ClaveInicio as ClaveInicio, @ClaveFin as ClaveFin
	exec RH.spBuscarEmpleados 
		--@EmpleadoFin = @ClaveInicio,
		--@EmpleadoIni = @ClaveFin,
		@dtFiltros=@dtFiltros,
		@IDUsuario= @IDUsuario
	--select *
	--from @dtFiltros
GO
