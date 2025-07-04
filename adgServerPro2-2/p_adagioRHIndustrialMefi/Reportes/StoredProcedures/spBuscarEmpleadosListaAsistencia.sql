USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spBuscarEmpleadosListaAsistencia] --'2019-06-22','2019-06-25',11,'24,2',1  
(  
  
 @FechaIni date,   
 @FechaFin date,     
 @IDTipoNomina int = 0,    
 @dtDepartamentos Varchar(max) = '',  
 @IDUsuario int  
  
)  
AS  
BEGIN  
  
  
  
  
   
 Declare @dtFiltros [Nomina].[dtFiltrosRH]  
   ,@dtEmpleados [RH].[dtEmpleados]  
   ,@Fechas [App].[dtFechas]  
  
 insert into @dtFiltros(Catalogo,Value)  
 values('Departamentos',@dtDepartamentos)  
  
  
  insert into @Fechas(Fecha)      
    exec [App].[spListaFechas]      
  @FechaIni = @FechaIni      
    , @FechaFin = @FechaFin     
  
 select f.Fecha,  
  m.ClaveEmpleado,  
  m.NOMBRECOMPLETO as NombreCompleto,  
  m.Departamento,  
  m.Puesto,  
  h.Codigo as CodigoHorario,   
  h.Descripcion as Horario,  
  (Select Min(Fecha) from Asistencia.tblChecadas where IDEmpleado = m.IDEmpleado and  FechaOrigen = f.Fecha and IDTipoChecada in ('SH','ET')) as Entrada,  
  (Select MAX(Fecha) from Asistencia.tblChecadas where IDEmpleado = m.IDEmpleado and FechaOrigen = f.Fecha and IDTipoChecada in ('SH','ST')) as Salida  
 from @Fechas f  
 cross apply Rh.tblEmpleadosMaster m  
  join  Seguridad.tblDetalleFiltrosEmpleadosUsuarios def on def.IDEmpleado = m.IDEmpleado and def.IDUsuario = @IDUsuario  
  left join Asistencia.tblHorariosEmpleados he  
   on f.Fecha = he.Fecha  
   and m.IDEmpleado = he.IDEmpleado  
  left join Asistencia.tblCatHorarios h  
   on he.IDHorario = h.IDHorario  
  
 where f.Fecha Between @FechaIni and @FechaFin  
 and ((M.IDTipoNomina = @IDTipoNomina))  
 and m.Vigente = 1
  and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))               
      or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))    
  ORDER BY F.fecha, m.claveEmpleado
    
END
GO
