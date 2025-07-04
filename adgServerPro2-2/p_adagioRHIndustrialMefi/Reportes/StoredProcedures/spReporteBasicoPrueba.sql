USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoPrueba](
	 @Puestos varchar(max) = ''
	,@IDUsuario int		
)
AS
	DECLARE
		@dtFiltros Nomina.dtFiltrosRH,
		@empleados RH.dtEmpleados
	;

	if (isnull(@Puestos,'') <> '')
	begin
		insert @dtFiltros(Catalogo,[Value])
		select 'Puestos',@Puestos
	end;

	insert @empleados
	exec RH.spBuscarEmpleados 
			@dtFiltros = @dtFiltros
			,@IDUsuario = @IDUsuario 

	select *
	from @empleados
GO
