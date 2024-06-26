USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Reportes.spReporteHorariosDescansos --@FechaIni = '2019-05-01' , @FechaFin = '2019-05-15' ,@IDUsuario = 1    
(    
  @FechaIni Date,     
  @FechaFin Date,     
   @IDCliente int = 0,      
  @IDTipoNomina int = 0,    
  @dtDepartamentos Varchar(max) = '',      
  @dtSucursales Varchar(max) = '',      
  @dtPuestos Varchar(max) = '',      
  @dtRazonSociales Varchar(max) = '',      
  @dtRegPatronales Varchar(max) = '',      
  @dtDivisiones Varchar(max) = '',    
  @IDUsuario int     
)    
AS    
BEGIN    
    
SET FMTONLY OFF;        
    
 Declare @dtFiltros [Nomina].[dtFiltrosRH],      
  @empleados [RH].[dtEmpleados],    
  @dtfechas [App].[dtFechas]    
        
    
    
 insert into @dtFiltros(Catalogo,Value)      
 values('Departamentos',isnull(@dtDepartamentos,''))      
      
 insert into @dtFiltros(Catalogo,Value)      
 values('Sucursales',isnull(@dtSucursales,''))      
       
 insert into @dtFiltros(Catalogo,Value)      
 values('Puestos',isnull(@dtPuestos,''))      
       
 insert into @dtFiltros(Catalogo,Value)      
 values('RazonesSociales',isnull(@dtRazonSociales,''))      
       
 insert into @dtFiltros(Catalogo,Value)      
 values('RegPatronales',isnull(@dtRegPatronales,''))       
      
 insert into @dtFiltros(Catalogo,Value)      
 values('Divisiones',isnull(@dtDivisiones,''))      
    
 insert into @dtFiltros(Catalogo,Value)      
 values('Clientes',case when isnull(@IDCliente,0) = 0 then '' else cast( @IDCliente as varchar(max)) END)       
    
 set @IDTipoNomina = CASE WHEN ISNULL(@IDTipoNomina,0) = 0 then 0 else @IDTipoNomina END     
    
 insert into @empleados      
 Exec [RH].[spBuscarEmpleadosMaster] @FechaIni = @FechaIni    
         , @FechaFin = @FechaFin    
         ,@IDTipoNomina=@IDTipoNomina    
         , @dtFiltros = @dtFiltros      
         ,@IDUsuario = @IDUsuario    
     
 --select * from @empleados     
    
  insert into @dtFechas    
  exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin    
    
  --select * from @dtfechas    
    
if object_id('tempdb..#tempVigenciaEmpleados') is not null        
    drop table #tempVigenciaEmpleados    
    
    
 Create Table #tempVigenciaEmpleados    
 (    
  IDEmpleado int null,    
  Fecha Date null,    
  Vigente bit null    
 )    
    
 insert into #tempVigenciaEmpleados    
 Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  @dtEmpleados = @empleados    
 ,@Fechas = @dtFechas    
 ,@IDUsuario = @IDUsuario    
    
    
 --select * from #tempVigenciaEmpleados    
    
    
    
 select tve.Fecha    
  ,e.IDEmpleado    
  ,e.ClaveEmpleado    
  ,e.NOMBRECOMPLETO    
  ,e.Departamento    
  ,e.Sucursal    
  ,e.Puesto    
  ,H.Codigo as CodigoHorario  
  ,H.Descripcion as Horario  
  ,H.HoraEntrada  
  ,H.HoraSalida  
  ,(select min(Fecha) from Asistencia.tblChecadas where FechaOrigen = tve.Fecha) as ChecadaEntrada  
  ,(select MAX(Fecha) from Asistencia.tblChecadas where FechaOrigen = tve.Fecha) as ChecadaSalida  
  ,I.Descripcion as Descanso  
 from #tempVigenciaEmpleados tve    
  inner join @empleados e    
   on tve.IDEmpleado = e.IDEmpleado    
  left join Asistencia.tblHorariosEmpleados HE  
 on HE.Fecha = tve.Fecha  
 and HE.IDEmpleado = TVE.IDEmpleado  
  left join Asistencia.tblCatHorarios H  
 on H.IDHorario = HE.IDHorario  
  left join Asistencia.tblIncidenciaEmpleado IE    
   on IE.IDEmpleado = e.IDEmpleado    
    and tve.Fecha = IE.Fecha    
  left join Asistencia.tblCatIncidencias I    
   on I.IDIncidencia = IE.IDIncidencia    
 and I.IDIncidencia = 'D'  
  left join Seguridad.tblUsuarios u     
   on IE.AutorizadoPor = U.IDUsuario     
 Where tve.Vigente = 1    
    
 Order by e.ClaveEmpleado asc, tve.Fecha asc    
    
    
    
    
    
END
GO
