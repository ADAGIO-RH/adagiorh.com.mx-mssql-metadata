USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Asistencia].[spBuscarIncidenciasEmpleadosAutorizacion](
	@IDIncidenciaEmpleado int = 0
	,@dtFiltros [Nomina].[dtFiltrosRH] readonly
   --,@FechaIni Date = '1900-01-01'
   --,@FechaFin Date =  '9999-12-31'
   --,@EmpleadoIni	Varchar(20) = '0'
   --,@EmpleadoFin	Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'
   --,@Incidencias	Varchar(MAX) = '*'
   --,@Ausentismos	Varchar(MAX) = '*'
   --,@Autorizaciones Varchar(MAX) = '*'
   --,@Departamentos	Varchar(MAX) = '*'
   --,@Sucursales		Varchar(MAX) = '*'
   --,@Puestos		Varchar(MAX) = '*'
   --,@ClasificacionesCorporativas Varchar(MAX) = '*'
   --,@Divisiones Varchar(MAX) = '*'  
   ,@IDUsuario int
)
AS
BEGIN
	SET DATEFIRST 7;

	declare 
		 @FechaIni Date = '1900-01-01'
		,@FechaFin Date =  '9999-12-31'
		,@EmpleadoIni	Varchar(20) = '0'
		,@EmpleadoFin	Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'
		,@Incidencias	Varchar(MAX) = '*'
		,@Ausentismos	Varchar(MAX) = '*'
		,@Autorizaciones Varchar(MAX) = '*'
		--,@Departamentos	Varchar(MAX) = '*'
		--,@Sucursales		Varchar(MAX) = '*'
		--,@Puestos		Varchar(MAX) = '*'
		--,@ClasificacionesCorporativas Varchar(MAX) = '*'
		--,@Divisiones Varchar(MAX) = '*'  
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	select @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL

	select @FechaIni =			CAST(CASE WHEN ISNULL(Value,'') = ''	THEN '1900-01-01'	ELSE Value END as date) from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin =			CAST(CASE WHEN ISNULL(Value,'') = ''	THEN '9999-12-31'	ELSE Value END as date) from @dtFiltros where Catalogo = 'FechaFin'
	select @EmpleadoIni =		CASE WHEN ISNULL(Value,'') = ''			THEN '0'			ELSE Value END from @dtFiltros where Catalogo = 'EmpleadoIni'
	select @EmpleadoFin =		CASE WHEN ISNULL(Value,'') = ''			THEN 'ZZZZZZZZZZ'	ELSE Value END from @dtFiltros where Catalogo = 'EmpleadoFin'
	select @Incidencias =		CASE WHEN ISNULL(Value,'') = ''			THEN '*' ELSE Value END from @dtFiltros where Catalogo = 'Incidencias'
	select @Ausentismos =		CASE WHEN ISNULL(Value,'') = ''			THEN '*' ELSE Value END from @dtFiltros where Catalogo = 'Ausentismos'
	select @Autorizaciones	=	CASE WHEN ISNULL(Value,'') = ''			THEN '*' ELSE Value END from @dtFiltros where Catalogo = 'Autorizaciones'

	select 
		IE.IDIncidenciaEmpleado
		,IE.IDEmpleado
		,EM.ClaveEmpleado
		,EM.NOMBRECOMPLETO as NombreCompleto
		,EM.Departamento
		,EM.Sucursal
		,EM.Puesto
		,IE.Fecha
		,substring(upper(DATENAME(weekday,IE.Fecha)),1,3) as Dia
		,ISNULL(H.Descripcion,'SIN HORARIO')	as		Horario
		,ISNULL(H.HoraEntrada,'00:00:00.000') as		HoraEntrada
		,ISNULL(H.HoraSalida,'00:00:00.000')		as	HoraSalida
		,ISNULL(H.JornadaLaboral,'00:00:00.000')	as	Jornada
		,ISNULL(cast(IE.Entrada as Time),'00:00:00.000') as	Entrada
		,ISNULL(cast(IE.Salida as Time),'00:00:00.000')  as	Salida
		,ISNULL(cast(IE.TiempoTrabajado as Time),'00:00:00.000')  as	TiempoTrabajado
		,I.IDIncidencia
		,JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
		,ISNULL(IE.TiempoSugerido,'00:00:00.000')		as TiempoSugerido 
		,ISNULL(IE.TiempoAutorizado,'00:00:00.000')	as TiempoAutorizado
		,ISNULL(IE.Autorizado,0)	as Autorizado
		,ISNULL(IE.ComentarioTextoPlano,'') as Comentario
		,IE.FechaHoraAutorizacion
	from Asistencia.tblIncidenciaEmpleado IE with (nolock)
		Inner join RH.tblEmpleadosMaster EM with (nolock) on IE.IDEmpleado = EM.IDEmpleado
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado 
			and dfe.IDUsuario = @IDUsuario
		left join Asistencia.tblCatHorarios H with (nolock) on IE.IDHorario = H.IDHorario
		left Join Asistencia.tblCatIncidencias I with (nolock) on IE.IDIncidencia = I.IDIncidencia
	WHERE ((IE.IDIncidenciaEmpleado = @IDIncidenciaEmpleado) or (@IDIncidenciaEmpleado = 0)) 
		AND (IE.Fecha BETWEEN @FechaIni and @FechaFin)
		AND (EM.ClaveEmpleado BETWEEN ISNULL(@EmpleadoIni,'0') and ISNULL(@EmpleadoFin,'ZZZZZZZZZZZZZZZZZZZZ'))
		AND ((I.IDIncidencia in (Select ITEM FROM App.Split(@Incidencias,',')))OR(@Incidencias = '*'))
		AND ((I.IDIncidencia in (Select ITEM FROM App.Split(@Ausentismos,',')))OR(@Ausentismos = '*'))
		AND ((@Autorizaciones = '*') OR (IE.Autorizado in (Select CAST(ITEM as BIT) FROM App.Split(CASE WHEN @Autorizaciones = '*' THEN '0,1' 
																										WHEN @Autorizaciones = '1' THEN '1' 
																										WHEN @Autorizaciones = '0' THEN '0' 
																										ELSE '' END,','))))
		AND ((EM.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))              
		AND ((EM.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))              
		AND ((EM.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))              
		AND ((EM.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))           
		AND ((EM.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))          
		AND ((EM.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))        
		AND ((EM.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))        
		AND ((EM.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))       
		AND ((EM.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))        
		AND ((EM.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		AND ((EM.IDCentroCosto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'CentrosCostos' and isnull(Value,'')<>''))) 
	
	--AND ((EM.IDDepartamento in (Select ITEM FROM App.Split(@Departamentos,',')))OR(@Departamentos = '*'))
		--AND ((EM.IDSucursal in (Select ITEM FROM App.Split(@Sucursales,',')))OR(@Sucursales = '*'))
		--AND ((EM.IDPuesto in (Select ITEM FROM App.Split(@Puestos,',')))OR(@Puestos = '*'))
		--AND ((EM.IDClasificacionCorporativa in (Select ITEM FROM App.Split(@ClasificacionesCorporativas,',')))OR(@ClasificacionesCorporativas = '*'))
		--AND ((EM.IDDivision in (Select ITEM FROM App.Split(@Divisiones,',')))OR(@Divisiones = '*'))
END
GO
