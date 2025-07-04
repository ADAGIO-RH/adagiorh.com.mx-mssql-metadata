USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Ocirre las Checadas de los calaboradores según los filtros  para ajustarlas a los tiempos   
      Extras autorizados u a los horarios en su caso de que no se autorizen los tiempos extra.  
** Autor   : Joseph Román    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-06-11    
** Paremetros  :                  
** DataTypes Relacionados:     
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/    
CREATE PROCEDURE [Asistencia].[spUChecadasEmpleadosParaCorregir] --@FechaIni = '2019-05-01 00:00:00', @FechaFin = '2019-06-30 00:00:00',  @IDUsuario = 1   
(    
    @FechaIni Date = '1900-01-01'    
   ,@FechaFin Date =  '9999-12-31'    
   ,@EmpleadoIni Varchar(20) = '0'    
   ,@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'    
   ,@dtDepartamentos Varchar(MAX) = ''    
   ,@dtSucursales Varchar(MAX) = ''    
   ,@dtPuestos Varchar(MAX) = ''    
   ,@dtClasificacionesCorporativas Varchar(MAX) = ''    
   ,@dtDivisiones Varchar(MAX) = ''      
   ,@IDUsuario int    
)    
AS    
BEGIN    
  DECLARE @dtFechas app.dtFechas,    
    @dtEmpleados [RH].[dtEmpleados],  
    @dtFiltros [Nomina].[dtFiltrosRH],  
    @IDChecada int,  
    @Minutes int,  
    @Seconds int,  
    @MinutesTime Time,  
    @SecondTime Time  
  
  
 set @EmpleadoIni = ISNULL(@EmpleadoIni,'0')  
 set @EmpleadoFin = ISNULL(@EmpleadoFin,'ZZZZZZZZZZZZZZZZZZZZ')  
  
  
 if(isnull(@dtDepartamentos,'') <> '')  
 BEGIN  
 insert into @dtFiltros(Catalogo,Value)  
 values('Departamentos',@dtDepartamentos)  
 END  
 if(isnull(@dtSucursales,'') <> '')  
 BEGIN  
 insert into @dtFiltros(Catalogo,Value)  
 values('Sucursales',@dtSucursales)  
 END  
 if(isnull(@dtPuestos,'') <> '')  
 BEGIN  
 insert into @dtFiltros(Catalogo,Value)  
 values('Puestos',@dtPuestos)  
 END  
 if(isnull(@dtDivisiones,'') <> '')  
 BEGIN  
 insert into @dtFiltros(Catalogo,Value)  
 values('Divisiones',@dtDivisiones)  
 END  
 if(isnull(@dtClasificacionesCorporativas,'') <> '')  
 BEGIN  
 insert into @dtFiltros(Catalogo,Value)  
 values('ClasificacionesCorporativas',@dtClasificacionesCorporativas)  
 END  
  
  
 --select * from @dtFiltros  
 --select @EmpleadoIni  
 --select @EmpleadoFin  
 --select @FechaIni  
 --select @FechaFin  
  
 insert into @dtEmpleados      
 Exec [RH].[spBuscarEmpleadosMaster] @FechaIni = @FechaIni    
          ,@FechaFin = @FechaFin  
    ,@EmpleadoIni = @EmpleadoIni  
    ,@EmpleadoFin = @EmpleadoFin  
    ,@dtFiltros = @dtFiltros   
    ,@IDUsuario = @IDUsuario   
  
  
  insert into @dtFechas    
  exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin    
  
  
    
  if object_id('tempdb..#tempVigenciaEmpleados') is not null        
    drop table #tempVigenciaEmpleados    
    
    
 Create Table #tempVigenciaEmpleados    
 (    
  IDEmpleado int null,    
  Fecha Date null,    
  Vigente bit null    
 );   
  
  
     
 insert into #tempVigenciaEmpleados    
 Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  @dtEmpleados = @dtEmpleados    
 ,@Fechas = @dtFechas    
 ,@IDUsuario = 1    
  
  
 delete  #tempVigenciaEmpleados    
  where Vigente = 0    
  
  
    
  if object_id('tempdb..#tempDatosChecadas') is not null        
    drop table #tempDatosChecadas    
      
  
  
  select   
  ve.Fecha  
  ,e.IDEmpleado  
  ,e.ClaveEmpleado  
  ,e.NOMBRECOMPLETO  
  ,h.Descripcion as Horario  
  ,h.HoraEntrada  
  ,h.HoraSalida  
  ,c.IDChecada  
  ,case when (IE.IDIncidenciaEmpleado is not null) and (IE.HorarioAD  = 'AE') and (c.IDTipoChecada =  'ET') THEN CAST(ve.Fecha as datetime)+ Cast(H.HoraEntrada as datetime) - cast( IE.TiempoAutorizado as datetime)   
        when (IE.IDIncidenciaEmpleado is not null) and (IE.HorarioAD  = 'DS') and (c.IDTipoChecada =  'ST')  THEN CAST(ve.Fecha as datetime)+ Cast(H.HoraSalida as datetime) + cast( IE.TiempoAutorizado as datetime)   
        when (IE.IDIncidenciaEmpleado is null) and (c.IDTipoChecada =  'ET')  THEN CAST(ve.Fecha as datetime)+ Cast(H.HoraEntrada as datetime)  
        when (IE.IDIncidenciaEmpleado is null) and (c.IDTipoChecada =  'ST')  THEN CAST(ve.Fecha as datetime)+ Cast(H.HoraSalida as datetime)  
     else c.FechaOriginal end FechaAjustada   
  ,c.FechaOriginal as FechaOriginal   
  ,c.IDTipoChecada  
  ,CAST(Case when c.Fecha <> c.FechaOriginal Then 1 ELSE 0 END as bit) AS Diferente  
 into #tempDatosChecadas  
  from #tempVigenciaEmpleados VE  
 inner join @dtEmpleados E  
  on E.IDEmpleado = VE.IDEmpleado  
 inner join Asistencia.tblChecadas c  
  on c.IDEmpleado = E.IDEmpleado  
  and c.FechaOrigen = VE.Fecha  
  and c.IDTipoChecada in ('ET','ST')  
 Inner join Asistencia.tblHorariosEmpleados HE  
  on HE.Fecha = VE.Fecha  
  and HE.IDEmpleado = E.IDEmpleado   
 inner join Asistencia.tblCatHorarios H  
  on H.IDHorario = HE.IDHorario  
 left join Asistencia.tblIncidenciaEmpleado IE  
  on IE.IDEmpleado = E.IDEmpleado  
   and IE.Fecha = VE.Fecha  
   and IE.IDIncidencia = 'EX'  
   and IE.Autorizado = 1  
where (( C.IDTipoChecada = 'ET' and c.Fecha < cast(VE.Fecha as datetime) + cast(h.HoraEntrada as datetime) )  
  OR( C.IDTipoChecada = 'ST' and c.Fecha > cast(VE.Fecha as datetime) + cast(h.HoraSalida as datetime)))  
      and ((C.IDTipoChecada = 'ET' and  datediff(minute,c.Fecha, cast(VE.Fecha as datetime) + cast(h.HoraEntrada as datetime)) > 10  )  
  OR(C.IDTipoChecada = 'ST' and  datediff(minute,cast(VE.Fecha as datetime) + cast(h.HoraEntrada as datetime),c.Fecha) > 10  ))  
ORDER BY  VE.Fecha ASC,  E.ClaveEmpleado ASC  
  
  
select @IDChecada = min(IDChecada) from #tempDatosChecadas  
  
while @IDChecada <= (select MAX(@IDChecada) from #tempDatosChecadas)  
BEGIN  
  
set @Minutes = cast(rand() * 9 + 1 as int);  
set @Seconds = cast(rand() * 59 + 1 as int);  
  
set @MinutesTime = cast(format(DATEADD(MINUTE,@minutes,CAST(CAST(0 AS FLOAT) AS DATETIME)),'HH:mm:ss') as time);   
set @SecondTime = cast(format(DATEADD(SECOND,@Seconds,CAST(CAST(0 AS FLOAT) AS DATETIME)),'HH:mm:ss') as time);   
  
  
  
 update c  
  set c.Fecha = case when dc.IDTipoChecada = 'ET' then   DC.FechaAjustada - cast(@MinutesTime as datetime)  - cast(@SecondTime as datetime)  
       else  DC.FechaAjustada + cast(@MinutesTime as datetime)  + cast(@SecondTime as datetime)   
       END  
 from Asistencia.tblChecadas c  
  inner join #tempDatosChecadas DC  
   on DC.IDChecada = C.IDChecada  
 where c.IDChecada = @IDChecada  
  
 set @IDChecada = (select min(IDChecada ) from #tempDatosChecadas where IDChecada > @IDChecada)  
  
END  
  
  
  
  
  
  
  
END
GO
