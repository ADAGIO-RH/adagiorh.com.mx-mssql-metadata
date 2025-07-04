USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarBitacoraChecadas]
(
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int  
)
AS
BEGIN
	SET NOCOUNT ON;
    IF 1=0 
	BEGIN
		SET FMTONLY OFF
    END

	declare
		 @FechaInicio		date --= '2019-05-01'
		,@FechaFin			date --= '2019-05-29'
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20)  
		
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	SET @FechaInicio	= (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin		= (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	SET @EmpleadoIni	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
	
	SET DATEFIRST 7;

	select top 1 @IDIdioma = dp.Valor
	from Seguridad.tblUsuarios u with (nolock)
		Inner join App.tblPreferencias p with (nolock)
			on u.IDPreferencia = p.IDPreferencia
		Inner join App.tblDetallePreferencias dp with (nolock)
			on dp.IDPreferencia = p.IDPreferencia
		Inner join App.tblCatTiposPreferencias tp with (nolock)
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia
		where u.IDUsuario = @IDUsuario
			and tp.TipoPreferencia = 'Idioma'

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL

	select 
		format(B.Fecha,'dd/MM/yyyy HH:mm:ss') as FECHA,
		M.ClaveEmpleado as [CLAVE EMPLEADO],
		M.NOMBRECOMPLETO as [NOMBRE COMPLETO],
		L.CodigoLector [COD. LECTOR],
		L.Lector as LECTOR,
		B.Mensaje as MENSAJE
	 from Asistencia.tblBitacoraChecadas B with (nolock)
		left join RH.tblEmpleadosMaster M with (nolock)
			on M.IDEmpleado = B.IDEmpleado
		left join Asistencia.tblLectores L with (nolock)
			on L.IDLector = B.IDLector
	Where cast(B.Fecha as date) Between @FechaInicio and @FechaFin
		and (M.ClaveEmpleado between @EmpleadoIni and @EmpleadoFin)

END
GO
