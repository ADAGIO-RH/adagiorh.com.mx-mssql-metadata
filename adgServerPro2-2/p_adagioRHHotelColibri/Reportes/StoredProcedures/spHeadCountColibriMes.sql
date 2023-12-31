USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spHeadCountColibriMes](
	 @Ejercicio int
	,@IDMes int
	,@IDMesFin int
    ,@Departamentos				  varchar(max) = ''
	,@Sucursales				  varchar(max) = ''
	,@Puestos					  varchar(max) = ''
	,@Prestaciones				  varchar(max) = ''
	,@TiposContratacion			  varchar(max) = ''
	,@RazonesSociales			  varchar(max) = ''
	,@RegPatronales				  varchar(max) = ''
	,@Divisiones				  varchar(max) = ''
	,@ClasificacionesCorporativas varchar(max) = ''
	,@CentrosCostos				  varchar(max) = ''
	,@Regiones					  varchar(max) = ''
)
AS

DECLARE 
	@FechaInicio date,
	@FechaFin date,
	@Fechas app.dtFechas,
	@dtEmpleados rh.dtEmpleados,
	@Fecha date,
	@day date ,
    @dtFiltros Nomina.dtFiltrosRH
	;


insert into @dtFiltros(Catalogo,Value)
	values
		('Departamentos',@Departamentos)
		,('RazonesSociales',@RazonesSociales)
		,('RegistrosPatronales',@RegPatronales)
		,('Regiones',@Regiones)
		,('Divisiones',@Divisiones)
		,('ClasificacionesCorporativas',@ClasificacionesCorporativas)
		,('CentrosCostos',@CentrosCostos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)

DECLARE @dtEmpleadosFecha as Table(
[IDEmpleado] [int] NULL,
	[ClaveEmpleado] [varchar](20) NULL,
	[RFC] [varchar](20) NULL,
	[CURP] [varchar](20) NULL,
	[IMSS] [varchar](20) NULL,
	[Nombre] [varchar](50) NULL,
	[SegundoNombre] [varchar](50) NULL,
	[Paterno] [varchar](50) NULL,
	[Materno] [varchar](50) NULL,
	[NOMBRECOMPLETO] [varchar](50) NULL,
	[IDLocalidadNacimiento] [int] NULL,
	[LocalidadNacimiento] [varchar](100) NULL,
	[IDMunicipioNacimiento] [int] NULL,
	[MunicipioNacimiento] [varchar](100) NULL,
	[IDEstadoNacimiento] [int] NULL,
	[EstadoNacimiento] [varchar](100) NULL,
	[IDPaisNacimiento] [int] NULL,
	[PaisNacimiento] [varchar](100) NULL,
	[FechaNacimiento] [date] NULL,
	[IDEstadoCiviL] [int] NULL,
	[EstadoCivil] [varchar](100) NULL,
	[Sexo] [varchar](15) NULL,
	[IDEscolaridad] [int] NULL,
	[Escolaridad] [varchar](100) NULL,
	[DescripcionEscolaridad] [varchar](100) NULL,
	[IDInstitucion] [int] NULL,
	[Institucion] [varchar](100) NULL,
	[IDProbatorio] [int] NULL,
	[Probatorio] [varchar](100) NULL,
	[FechaPrimerIngreso] [date] NULL,
	[FechaIngreso] [date] NULL,
	[FechaAntiguedad] [date] NULL,
	[Sindicalizado] [bit] NULL,
	[IDJornadaLaboral] [int] NULL,
	[JornadaLaboral] [varchar](100) NULL,
	[UMF] [varchar](10) NULL,
	[CuentaContable] [varchar](50) NULL,
	[IDTipoRegimen] [int] NULL,
	[TipoRegimen] [varchar](200) NULL,
	[IDPreferencia] [int] NULL,
	[IDDepartamento] [int] NULL,
	[Departamento] [App].[MDDescription] NULL,
	[IDSucursal] [int] NULL,
	[Sucursal] [App].[MDDescription] NULL,
	[IDPuesto] [int] NULL,
	[Puesto] [App].[MDDescription] NULL,
	[IDCliente] [int] NULL,
	[Cliente] [App].[MDDescription] NULL,
	[IDEmpresa] [int] NULL,
	[Empresa] [App].[MDDescription] NULL,
	[IDCentroCosto] [int] NULL,
	[CentroCosto] [App].[MDDescription] NULL,
	[IDArea] [int] NULL,
	[Area] [App].[MDDescription] NULL,
	[IDDivision] [int] NULL,
	[Division] [App].[MDDescription] NULL,
	[IDRegion] [int] NULL,
	[Region] [App].[MDDescription] NULL,
	[IDClasificacionCorporativa] [int] NULL,
	[ClasificacionCorporativa] [App].[MDDescription] NULL,
	[IDRegPatronal] [int] NULL,
	[RegPatronal] [App].[MDDescription] NULL,
	[IDTipoNomina] [int] NULL,
	[TipoNomina] [App].[MDDescription] NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[SalarioDiarioReal] [decimal](18, 2) NULL,
	[SalarioIntegrado] [decimal](18, 2) NULL,
	[SalarioVariable] [decimal](18, 2) NULL,
	[IDTipoPrestacion] [int] NULL,
	[IDRazonSocial] [int] NULL,
	[RazonSocial] [App].[MDDescription] NULL,
	[IDAfore] [int] NULL,
	[Afore] [varchar](max) NULL,
	[Vigente] [bit] NULL,
	[RowNumber] [int] NULL,
	[ClaveNombreCompleto] [varchar](500) NULL,
	[PermiteChecar] [bit] NULL,
	[RequiereChecar] [bit] NULL,
	[PagarTiempoExtra] [bit] NULL,
	[PagarPrimaDominical] [bit] NULL,
	[PagarDescansoLaborado] [bit] NULL,
	[PagarFestivoLaborado] [bit] NULL,
	[IDDocumento] [int] NULL,
	[Documento] [varchar](max) NULL,
	[IDTipoContrato] [int] NULL,
	[TipoContrato] [varchar](max) NULL,
	[FechaIniContrato] [date] NULL,
	[FechaFinContrato] [date] NULL,
	[TiposPrestacion] [varchar](max) NULL,
	[tipoTrabajadorEmpleado] [varchar](max) NULL,
	[Fecha] [varchar](max) NULL
);

	SELECT @FechaInicio = cast(cast(@Ejercicio*10000 + @IDMes*100 + 1 as varchar(255)) as date)
	SELECT @FechaFin = EOMONTH(cast(cast(@Ejercicio*10000 + @IDMesFin*100 + 1 as varchar(255)) as date))
	SELECT @day = @FechaInicio

	--select @FechaInicio,@FechaFin

	INSERT INTO @Fechas
	EXEC [App].[spListaFechas]@FechaInicio,@FechaFin

	--select * from @Fechas

	WHILE @day <= (SELECT MAX(Fecha) from @Fechas)
	BEGIN
		print @day
		INSERT INTO @dtEmpleados
		EXEC RH.spBuscarEmpleados @FechaIni= @day, @FechaFin = @day, @IDUsuario = 1, @dtfiltros = @dtfiltros

		insert into @dtEmpleadosFecha
		select * , month(@Day)
		from @dtEmpleados

		DELETE @dtEmpleados

		SET @day = DATEADD(day, 1, @day)
	END


select 
    Sucursal,
	Departamento,
	Puesto,
	CASE WHEN Fecha = 1 then '01'
		 WHEN Fecha = 2 then '02'
		 WHEN Fecha = 3 then '03'
		 WHEN Fecha = 4 then '04'
		 WHEN Fecha = 5 then '05'
		 WHEN Fecha = 6 then '06'
		 WHEN Fecha = 7 then '07'
		 WHEN Fecha = 8 then '08'
		 WHEN Fecha = 9 then '09'
		 ELSE Fecha
	END as Fecha
	,CASE WHEN Fecha = 1 then 'ENERO'
		 WHEN Fecha = 2 then 'FEBRERO'
		 WHEN Fecha = 3 then 'MARZO'
		 WHEN Fecha = 4 then 'ABRIL'
		 WHEN Fecha = 5 then 'MAYO'
		 WHEN Fecha = 6 then 'JUNIO'
		 WHEN Fecha = 7 then 'JULIO'
		 WHEN Fecha = 8 then 'AGOSTO'
		 WHEN Fecha = 9 then 'SEPTIEMBRE'
		 WHEN Fecha = 10 then 'OCTUBRE'
		 WHEN Fecha = 11 then 'NOVIEMBRE'
		 WHEN Fecha = 12 then 'DICIEMBRE'
	END as FechaMes
    ,CASE WHEN Fecha = 1 then datediff(day,'01-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '01-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 2 then  datediff(day,'02-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '02-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 3 then  datediff(day,'03-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '03-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 4 then  datediff(day,'04-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '04-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 5 then  datediff(day,'05-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '05-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 6 then  datediff(day,'06-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '06-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 7 then  datediff(day,'07-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '07-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 8 then  datediff(day,'08-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '08-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 9 then  datediff(day,'09-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '09-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 10 then  datediff(day,'10-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '10-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 11 then  datediff(day,'11-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '11-01-'+cast(@ejercicio as varchar)))
		 WHEN Fecha = 12 then  datediff(day,'12-01-'+cast(@ejercicio as varchar), dateadd(month, 1, '12-01-'+cast(@ejercicio as varchar)))
	END as DiasMes
	,Count(*) Qty
from @dtEmpleadosFecha
Group by Departamento,
    Sucursal,
	Puesto,
	Fecha
order by Fecha    

GO
