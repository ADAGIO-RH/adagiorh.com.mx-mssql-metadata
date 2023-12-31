USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from RH.tblEmpleados where ClaveEmpleado = 'JM00604'
--select * from nomina.tblCatTipoNomina
CREATE PROCEDURE [Reportes].[spSolicitudesVacacionesRD] --577, 99, 1     
(      
  @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
  @IDUsuario int      
)      
AS      
BEGIN      
       
DECLARE       
  @empleados [RH].[dtEmpleados],
  @FechaIni date,
  @FechaFin date 


  select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'    
      
    insert into @empleados      
    exec [RH].[spBuscarEmpleadosMaster] @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario      
     
 
	  
    Select M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
		,M.region as REGION
		,TS.Descripcion as TipoSolicitud
		,ES.Descripcion as Estatus
		,SE.IDIncidencia 
		,I.Descripcion as Incidencia
		,isnull(CONVERT(varchar,SE.FechaIni,23),'9999-12-31') as Fecha
		,ISNULL(SE.CantidadDias,0) as Días
        ,convert(varchar, SE.FechaCreacion, 23) as FechaSolicitud
    	,Utilerias.fnHTMLStr(SE.ComentarioEmpleado) as [COMENTARIOS EMPLEADO]
        --,SE.ComentarioEmpleado
		--,SE.ComentarioSupervisor        
        ,Utilerias.fnHTMLStr(SE.ComentarioSupervisor) as [COMENTARIOS SUPERVISOR]
		,SE.DiasDescanso
		,CASE WHEN us.Nombre IS NOT NULL THEN CONCAT(isnull(us.Nombre,'') ,' ',isnull(us.Apellido,''))
        ELSE (Select top 1 CONCAT(EMP.Nombre,' ',EMP.Paterno) from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado) END AS UsuarioAutoriza 
    from 
    Intranet.tblSolicitudesEmpleado se 
   INNER JOIN @empleados M 
			on SE.IDEmpleado = M.IDEmpleado
		INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK)
			on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK)
			on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK)
			on SE.IDIncidencia = I.IDIncidencia
        left join Seguridad.tblUsuarios us on us.IDUsuario= SE.IDUsuarioAutoriza
    where se.IDIncidencia = 'V' and se.FechaIni BETWEEN @FechaIni and @FechaFin

END
GO
