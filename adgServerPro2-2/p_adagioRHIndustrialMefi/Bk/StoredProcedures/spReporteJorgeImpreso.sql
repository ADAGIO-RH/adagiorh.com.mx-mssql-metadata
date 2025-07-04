USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec Bk.spReporteJorgeImpreso 
	@ClaveEmpleadoInicial=NULL,
	@ClaveEmpleadoFinal=NULL,
	@Clientes='2',
	@Divisiones=NULL,
	@TipoVigente=NULL,
	@IDUsuario=1
GO
*/
CREATE proc [BK].[spReporteJorgeImpreso](
	@ClaveEmpleadoInicial varchar(20)
	,@ClaveEmpleadoFinal	  varchar(20)
	,@Clientes varchar(max)
	,@Divisiones varchar(max)
	,@TipoVigente varchar(max) = '1'
	,@IDUsuario int
) as

	declare 
		@dtFiltros Nomina.dtFiltrosRH
	;

	--if (len(isnull(@Clientes,'')) > 0) 
	--begin
	--	insert @dtFiltros(Catalogo, [Value])
	--	values('Clientes', @Clientes)
	--end

	--if (len(isnull(@Divisiones,'')) > 0) 
	--begin
	--	insert @dtFiltros(Catalogo, [Value])
	--	values('Divisiones', @Divisiones)
	--end


	insert into @dtFiltros(Catalogo,Value)
	values
		 ('Divisiones',@Divisiones)
		,('Clientes',@Clientes)

	exec RH.spBuscarEmpleados 
		@EmpleadoFin = @ClaveEmpleadoInicial,
		@EmpleadoIni = @ClaveEmpleadoFinal,
		@dtFiltros=@dtFiltros,
		@IDUsuario= @IDUsuario
GO
