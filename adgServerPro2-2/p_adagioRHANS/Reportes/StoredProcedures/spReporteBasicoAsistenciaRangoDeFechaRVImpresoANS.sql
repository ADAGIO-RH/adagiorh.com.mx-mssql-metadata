USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Reportes].[spReporteBasicoAsistenciaRangoDeFechaRVImpresoANS] (    
 @FechaIni date     
 ,@FechaFin date    
 ,@Cliente varchar(max)   = ''        
 ,@TipoNomina varchar(max)  = ''        
 ,@Divisiones varchar(max)   = ''    
 ,@CentrosCostos varchar(max) = ''    
 ,@Departamentos varchar(max) = ''    
 ,@Areas varchar(max)    = ''    
 ,@Sucursales varchar(max)  = ''    
 ,@Prestaciones varchar(max)  = ''    
 ,@IDUsuario int    
) as    
    
 SET NOCOUNT ON;    
 IF 1=0 BEGIN    
  SET FMTONLY OFF    
 END    
    
 --declare     
 -- @FechaIni date =  '2019-08-01'    
 -- ,@FechaFin date = '2019-08-15'    
 -- ,@IDUsuario int = 1    
 --;    
    
 declare     
  @IDIdioma Varchar(5)      
  ,@IdiomaSQL varchar(100) = null      
  ,@Fechas [App].[dtFechasFull]       
  ,@dtEmpleados RH.dtEmpleados    
  ,@dtFiltros [Nomina].[dtFiltrosRH]      
  ,@IDTipoNominaInt int
  ,@Titulo Varchar(max)     
 ;    
    
 SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@TipoNomina,',')),0)    
    
 insert @dtFiltros(Catalogo,Value)        
 values    
  ('Clientes',@Cliente)        
  ,('Divisiones',@Divisiones)        
  ,('CentrosCostos',@CentrosCostos)        
  ,('Departamentos',@Departamentos)        
  ,('Areas',@Areas)        
  ,('Sucursales',@Sucursales)        
  ,('Prestaciones',@Prestaciones)        
    
 if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;      
 if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;        
 if object_id('tempdb..#tempFestivos') is not null drop table #tempFestivos;       
 SET DATEFIRST 7;     
 SET LANGUAGE spanish; 
      
 select top 1 @IDIdioma = dp.Valor      
 from Seguridad.tblUsuarios u      
  Inner join App.tblPreferencias p      
   on u.IDPreferencia = p.IDPreferencia      
  Inner join App.tblDetallePreferencias dp      
   on dp.IDPreferencia = p.IDPreferencia      
  Inner join App.tblCatTiposPreferencias tp      
   on tp.IDTipoPreferencia = dp.IDTipoPreferencia      
 where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'      
      
 select @IdiomaSQL = [SQL]      
 from app.tblIdiomas      
 where IDIdioma = @IDIdioma      
      
 if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)      
 begin      
  set @IdiomaSQL = 'Spanish' ;      
 end      
        
 SET LANGUAGE @IdiomaSQL;     
    
 insert @Fechas      
 exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin      
    
SET @Titulo =  UPPER( 'LISTA DE ASISTENCIA DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

 --select *    
 --from @Fechas    
    
 insert @dtEmpleados      
 exec [RH].[spBuscarEmpleados]       
  @FechaIni = @FechaIni               
  ,@FechaFin = @FechaFin        
  ,@IDTipoNomina = @IDTipoNominaInt             
  ,@IDUsuario = @IDUsuario                    
  ,@dtFiltros = @dtFiltros     
    
	select c.*
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join @Fechas fecha on c.FechaOrigen = fecha.Fecha 
		join @dtEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado  

 select ie.*    
 into #tempAusentismosIncidencias    
 from Asistencia.tblIncidenciaEmpleado ie with (nolock)    
  join @Fechas fecha on ie.Fecha = fecha.Fecha     
  join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado     
 where IE.IDIncidencia in (select IDIncidencia from Asistencia.tblCatIncidencias where EsAusentismo = 1 and IDIncidencia <> 'DL')    
  
  select * 
		into #tempFestivos
	from Asistencia.TblCatDiasFestivos with(nolock)
	where  isnull(Autorizado,0) = 1
   

 --select * from @Fechas    
 select    
   empFecha.ClaveEmpleado    
  ,empFecha.NOMBRECOMPLETO as Nombre    
  ,empFecha.Puesto   
  ,empFecha.RazonSocial  
  ,empFecha.RegPatronal  
  ,empFecha.Departamento 
  ,empFecha.Fecha    
  ,FechaStr = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)    
     +'/'+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))    
     +' '+ UPPER(SUBSTRING(empFecha.NombreDia,1,3))    
  ,cast(
  
		CASE WHEN EXISTS((select top 1 cast(cast(Fecha as time) as varchar(8))    
						 from #tempChecadas   
						 where FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado 
						 and IDTipoChecada in ('ET','SH')
						 order by Fecha asc)) THEN ((select top 1 cast(cast(Fecha as time) as varchar(5))    
													 from #tempChecadas   
													 where FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado 
													 and IDTipoChecada in ('ET','SH')
													 order by Fecha asc))
		ELSE 
			CASE WHEN I.IDIncidencia is not null THEN I.IDIncidencia
				 WHEN fest.IDDiaFestivo is not null THEN 'Fest.'
				ELSE 'NC'
				END
		END as varchar(max)) HoraEntrada 
         
  ,CAST(
	CASE WHEN EXISTS((select top 1 cast(cast(Fecha as time) as varchar(8))    
						 from #tempChecadas   
						 where FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado 
						 and IDTipoChecada in ('ST','SH')
						 order by Fecha desc)) THEN ((select top 1 cast(cast(Fecha as time) as varchar(5))    
													 from #tempChecadas   
													 where FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado 
													 and IDTipoChecada in ('ST','SH')
													 order by Fecha desc))
		ELSE 
			CASE WHEN I.IDIncidencia is not null THEN I.IDIncidencia
				 WHEN fest.IDDiaFestivo is not null THEN 'Fest.'
				ELSE 'NC'
				END
		END
  As varchar(max)) HoraSalida     
  --,i.IDIncidencia    
  ,i.Comentario    
  ,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(empFecha.Puesto,'')    
  --,Titulo = 'LISTA DE HORARIOS Y DESCANSOS DEL '    
  --   + App.fnAddString(2,cast(DATEPART(DAY,@FechaIni) as varchar(2)),'0',1)    
  --   +'/'+UPPER(cast(FORMAT(@FechaIni,'MMMM') as varchar))                        --UPPER(DATENAME(month,@FechaIni))    
  --   +'/'+CAST(DATEPART(YEAR,@FechaIni) as varchar)    
  --   +' AL '    
  --   + App.fnAddString(2,cast(DATEPART(DAY,@FechaFin) as varchar(2)),'0',1)    
  --   +'/'+UPPER(cast(FORMAT(@FechaFin,'MMMM') as varchar))                                   --UPPER(DATENAME(month,@FechaFin))    
  --   +'/'+CAST(DATEPART(YEAR,@FechaFin) as varchar) --{FECHA INICIAL CON FORMATO DD / Mes con Letra Completo / AÑO (4 dígitos)} AL FECHA FINAL    
 ,@Titulo as Titulo
 from (select *    
   from @Fechas    
    ,@dtEmpleados) as empFecha    
  left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha    
  	left join #tempFestivos fest on empFecha.Fecha = fest.Fecha   
 order by empFecha.ClaveEmpleado,empFecha.Fecha
GO
