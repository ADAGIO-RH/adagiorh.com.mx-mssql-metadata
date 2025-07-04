USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteIncidenciasAusentismos](
	@FechaIni		date, 
	@FechaFin		date, 
	@IDCliente		int = 0,  
	@IDTipoNomina	int = 0,
	@dtIncidenciasAusentismos	varchar(max) = '',  
	@dtDepartamentos			varchar(max) = '',  
	@dtSucursales				varchar(max) = '',  
	@dtPuestos			varchar(max) = '',  
	@dtRazonSociales	varchar(max) = '',  
	@dtRegPatronales	varchar(max) = '',  
	@dtDivisiones		varchar(max) = '',
	@IDUsuario			int	
)
AS
BEGIN

	SET FMTONLY OFF;    

	declare 
		@IDIdioma varchar(225),
		@dtFiltros [Nomina].[dtFiltrosRH],  
		@empleados [RH].[dtEmpleados],
		@dtfechas [App].[dtFechas]
	;  

	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	insert into @dtFiltros(Catalogo,Value)  
	values('Departamentos',isnull(@dtDepartamentos,''))  
		,('Sucursales',isnull(@dtSucursales,''))  
		,('Puestos',isnull(@dtPuestos,''))  
		,('RazonesSociales',isnull(@dtRazonSociales,''))  
		,('RegPatronales',isnull(@dtRegPatronales,''))   
		,('Divisiones',isnull(@dtDivisiones,''))  
		,('Clientes',case when isnull(@IDCliente,0) = 0 then '' else cast( @IDCliente as varchar(max)) END)   

	set @IDTipoNomina = CASE WHEN ISNULL(@IDTipoNomina,0) = 0 then 0 else @IDTipoNomina END 

	insert into @empleados  
	exec [RH].[spBuscarEmpleadosMaster] 
		@FechaIni	= @FechaIni
		,@FechaFin	= @FechaFin
		,@IDTipoNomina	= @IDTipoNomina
		,@dtFiltros		= @dtFiltros  
		,@IDUsuario		= @IDUsuario

	insert into @dtFechas
	exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin

	if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados

	create Table #tempVigenciaEmpleados(
		IDEmpleado int null,
		Fecha Date null,
		Vigente bit null
	)

	insert into #tempVigenciaEmpleados
	exec [RH].[spBuscarListaFechasVigenciaEmpleado]  
		@dtEmpleados = @empleados
		,@Fechas	= @dtFechas
		,@IDUsuario = @IDUsuario

	select tve.Fecha
		,e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,I.IDIncidencia
		,JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,IE.Comentario
		,IE.Autorizado
		,IE.TiempoAutorizado 
		,IE.TiempoExtraDecimal 
		,IE.TiempoSugerido
		,U.Cuenta as CuentaAutoriza 
		,substring(UPPER(COALESCE(U.Nombre,'')+' '+COALESCE(U.Apellido,'')),1,49 ) as CuentaAutoriza
	from #tempVigenciaEmpleados tve
		inner join @empleados e on tve.IDEmpleado = e.IDEmpleado
		inner join Asistencia.tblIncidenciaEmpleado IE on IE.IDEmpleado = e.IDEmpleado and tve.Fecha = IE.Fecha
		inner join Asistencia.tblCatIncidencias I on I.IDIncidencia = IE.IDIncidencia
		left join Seguridad.tblUsuarios u on IE.AutorizadoPor = U.IDUsuario 
	where tve.Vigente = 1
	 and ((I.IDIncidencia in (Select item from app.Split(@dtIncidenciasAusentismos,','))) OR isnull(@dtIncidenciasAusentismos,'') = '')
	order by e.ClaveEmpleado asc, tve.Fecha asc

END
GO
