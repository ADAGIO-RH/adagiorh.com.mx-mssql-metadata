USE [p_adagioRHBeHoteles]
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
/*
declare @p2 Nomina.dtFiltrosRH
insert into @p2 values(N'Empleados',N'240')
insert into @p2 values(N'FechaIni',N'2021-11-25')
insert into @p2 values(N'FechaFin',N'2021-11-25')
insert into @p2 values(N'IDUsuario',N'1')*/

    Declare 
	@Empleados  varchar(max) = null,
	@FechaIni varchar(max) = null,
	@FechaFin varchar(max)= null;
	
     
	SET @FechaIni = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),convert(varchar, getdate(), 23))
    SET @FechaFin = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),convert(varchar, getdate(), 23))
    SET @Empleados = isnull((Select top 1 cast(item as Varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),',')),'0')


	SELECT 	 
  
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
		,TS.Descripcion as TipoSolicitud
		,ES.Descripcion as Estatus
		,SE.IDIncidencia 
		,I.Descripcion as Incidencia
		,isnull(SE.FechaIni,'9999-12-31') as Fecha
		,ISNULL(SE.CantidadDias,0) as Días
        ,convert(varchar, SE.FechaCreacion, 23) as FechaSolicitud
    	,SE.ComentarioEmpleado
		,SE.ComentarioSupervisor        
		,SE.DiasDescanso
		,SE.FechaCreacion 
		,isnull(SE.IDUsuarioAutoriza,0) as IDUsuarioAutoriza		
	FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
		INNER JOIN RH.tblEmpleadosMaster M WITH(NOLOCK)
			on SE.IDEmpleado = M.IDEmpleado
		INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK)
			on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK)
			on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK)
			on SE.IDIncidencia = I.IDIncidencia
	WHERE 
             CAST( SE.FechaCreacion as date) BETWEEN CAST( @FechaIni as date)  and CAST(@FechaFin as date)  
             and (se.IDEmpleado = isnull(@Empleados,0)
				or isnull(@Empleados,0) = 0)
	--AND (SE.IDEmpleado = @IDEmpleado  OR @IDEmpleado = 0)
	--AND (SE.IDTipoSolicitud = @IDTipoSolicitud OR @IDTipoSolicitud = 0)
	--AND (SE.IDEstatusSolicitud = @IDEstatusSolicitud OR @IDEstatusSolicitud = 0)
	ORDER BY SE.FechaCreacion DESC
END
GO
