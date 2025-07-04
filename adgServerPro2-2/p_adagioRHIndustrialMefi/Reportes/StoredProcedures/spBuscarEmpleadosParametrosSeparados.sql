USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spBuscarEmpleadosParametrosSeparados] --@IDPeriodo = 1
(

 @IDPeriodo int = 0, 
 @EmpleadoIni Varchar(20) = '0',    
 @EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',    
 @dtDepartamentos Varchar(max) = '',
 @dtSucursales Varchar(max) = '',
 @dtPuestos Varchar(max) = '',
 @IDUsuario int
)
AS
BEGIN
	
	Declare @dtFiltros [Nomina].[dtFiltrosRH],
			@FechaIni Date,
			@FechaFin Date,
			@IDTipoNomina int
			;
	if(@IDPeriodo <> 0)
	BEGIN
		select @FechaIni = FechaInicioPago,
			@FechaFin = FechaFinPago,
			@IDTipoNomina = IDTipoNomina
		from Nomina.tblCatPeriodos
		where IDPeriodo = @IDPeriodo
	END
	ELSE
	BEGIN
		select @FechaIni = '1900-01-01',
				@FechaFin = '9999-12-31',
				@IDTipoNomina = 0	
	END

	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@dtDepartamentos)

	insert into @dtFiltros(Catalogo,Value)
	values('Sucursales',@dtSucursales)
	
	insert into @dtFiltros(Catalogo,Value)
	values('Puestos',@dtPuestos)

	Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
END
GO
