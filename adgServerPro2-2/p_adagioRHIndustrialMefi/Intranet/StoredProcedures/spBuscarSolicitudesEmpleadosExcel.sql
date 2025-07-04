USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarSolicitudesEmpleadosExcel](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN

    SET LANGUAGE Spanish;

    declare  
		@IDIdioma varchar(225),
		@Empleados  varchar(max) = null,
		@FechaIni varchar(max) = null,
		@FechaFin varchar(max)= null;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
    
	set @FechaIni = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),convert(varchar, getdate(), 23))
    set @FechaFin = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),convert(varchar, getdate(), 23))
    set @Empleados = isnull((Select top 1 cast(item as Varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),',')),'0')

	SELECT 	 
		M.ClaveEmpleado as [Clave Empleado]
		,M.NOMBRECOMPLETO as NombreCompleto
		,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [Tipo Solicitud]
		,JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Estatus
		,SE.IDIncidencia 
		,JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia	
        ,FORMAT(SE.FechaIni,'dd/MM/yyyy') as Fecha
		,ISNULL(SE.CantidadDias,0) as Día 
        ,FORMAT(SE.FechaCreacion,'dd/MM/yyyy') as [Fecha Solicitud]
    	,SE.ComentarioEmpleado
		,SE.ComentarioSupervisor    
        ,(
            SELECT STUFF((
                 SELECT ',' + DATENAME(WEEKDAY, DATEADD(DAY, CAST(item AS INT) -2, '1900-01-01'))
                    FROM app.split(SE.DiasDescanso, ',')
                    FOR XML PATH('')), 1, 1, '') AS DiasConcatenados
                    
        ) as [Dias de Descanso]	
        ,CONCAT(US.Cuenta,'-',US.Nombre,' ',US.Apellido) as [Usuario Autoriza]
	FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
		INNER JOIN RH.tblEmpleadosMaster M WITH(NOLOCK) on SE.IDEmpleado = M.IDEmpleado
		INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK) on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK) on SE.IDIncidencia = I.IDIncidencia
        LEFT JOIN Seguridad.tblUsuarios US WITH(NOLOCK) on US.IDUsuario=SE.IDUsuarioAutoriza
	WHERE CAST( SE.FechaCreacion as date) BETWEEN CAST( @FechaIni as date)  and CAST(@FechaFin as date)  
             and (se.IDEmpleado = isnull(@Empleados,0) or isnull(@Empleados,0) = 0)
	ORDER BY SE.FechaCreacion DESC
END
GO
