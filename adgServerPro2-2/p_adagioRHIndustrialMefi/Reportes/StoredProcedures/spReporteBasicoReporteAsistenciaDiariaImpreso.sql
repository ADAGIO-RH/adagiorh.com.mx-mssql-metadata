USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE proc [Reportes].[spReporteBasicoReporteAsistenciaDiariaImpreso]  (        
  @Clientes varchar(max) = '',      
  @IDTipoNomina varchar(max) = '',      
  @ClaveEmpleadoInicial Varchar(max)= '0',        
  @ClaveEmpleadoFinal Varchar(max) = 'ZZZZZZZZZZZZZZZZZZZZ',    
  @RazonesSociales varchar(max)= '',      
  @RegPatronales varchar(max)= '',     
  @Regiones varchar(max)= '',  
  @Divisiones varchar(max)= '',
  @CentrosCostos varchar(max)= '',   
  @Departamentos varchar(max),   
  @ClasificacionesCorporativas varchar(max)= '', 
  @Areas varchar(max)= '', 
  @Sucursales varchar(max)= '',  
  @Puestos varchar(max)= '', 
  @TiposPrestaciones varchar(max)= '',
  @FechaIni varchar(max)= '', 
  @IDTurno varchar(max)= '', 
  @IDUsuario int        
) as        
 SET FMTONLY OFF     
 declare @empleados [RH].[dtEmpleados]            
  ,@IDPeriodoSeleccionado int=0            
  ,@periodo [Nomina].[dtPeriodos]            
  ,@configs [Nomina].[dtConfiguracionNomina]            
  ,@Conceptos [Nomina].[dtConceptos]            
  ,@fechaIniPeriodo  date            
  ,@fechaFinPeriodo  date         
  ,@dtFiltros Nomina.dtFiltrosRH         
 ;        
   
 DECLARE     
 @IDCliente int,    
 @IDTipoNominaInt int,    
 @EmpleadoIni varchar(20),    
 @EmpleadoFin varchar(20),    
 @Fecha Datetime,    
 @IDTurnoInt int ,
 @IDIdioma varchar(max)


 select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
  
 SET @IDCliente = (Select top 1 cast(item as int) from App.Split(@Clientes,','))    
 SET @IDTipoNominaInt = (Select top 1 cast(item as int) from App.Split(@IDTipoNomina,','))    
 SET @EmpleadoIni = isnull((Select top 1 cast(item as Varchar(20)) from App.Split(@ClaveEmpleadoInicial,',')),'0')    
 SET @EmpleadoFin = isnull((Select top 1 cast(item as Varchar(20)) from App.Split(@ClaveEmpleadoFinal,',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')    
 SET @Fecha = (Select top 1 cast(item as datetime) from App.Split(@FechaIni,','))    
 SET @IDTurnoInt = (Select top 1 cast(item as int) from App.Split(@IDTurno,','))    
  
  
 --select @IDCliente, @IDTipoNominaInt, @EmpleadoIni, @EmpleadoFin, @Fecha, @IDTurnoInt  
  
  
  
 insert into @dtFiltros(Catalogo,Value)      
 values('RazonesSociales',@RazonesSociales)      
    ,('RegPatronales',@RegPatronales)      
    ,('Sucursales',@Sucursales)      
    ,('Regiones',@Regiones)      
    ,('CentrosCostos',@CentrosCostos)      
    ,('Departamentos',@Departamentos)      
    ,('Areas',@Areas)      
    ,('Puestos',@Puestos)      
    ,('TiposPrestaciones',@TiposPrestaciones)      
    ,('ClasificacionesCorporativas',@ClasificacionesCorporativas)      
  
      
 /* Se buscan el periodo seleccionado */        
   insert into @empleados                  
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNominaInt,@FechaIni=@Fecha, @Fechafin = @Fecha, @dtFiltros = @dtFiltros,@EmpleadoIni = @EmpleadoIni,@EmpleadoFin = @EmpleadoFin, @IDUsuario = @IDUsuario        
    
  
      select     
     E.ClaveEmpleado    
    ,E.NOMBRECOMPLETO as NombreCompleto    
    ,E.Empresa    
    ,E.Division    
    ,E.RegPatronal    
    ,E.Sucursal    
    ,E.CentroCosto    
    ,E.Departamento    
    ,E.Area    
    ,E.Puesto    
    ,isnull(h.Codigo,'SIN HORARIO') as Horario    
    ,TCH.IDTipoChecada as IDTipoChecada  
 ,JSON_VALUE(TCH.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as TipoChecada  
 ,CASE WHEN TCH.IDTipoChecada = 'ET' THEN 1
	   WHEN TCH.IDTipoChecada = 'SC' THEN 2
	   WHEN TCH.IDTipoChecada = 'EC' THEN 3
	   WHEN TCH.IDTipoChecada = 'ST' THEN 4
	   ELSE 5
	END as Orden

 ,(Select Top 1 Fecha from Asistencia.tblChecadas where FechaOrigen = isnull(HE.Fecha,@FechaIni) and IDEmpleado = E.IDEmpleado and IDTipoChecada = TCH.IDTipoChecada) as Checada  
    from @empleados E    
    left join Asistencia.tblHorariosEmpleados HE    
     on HE.IDEmpleado = E.IDEmpleado    
     and HE.Fecha =@Fecha  
    left join Asistencia.tblCatHorarios H    
     on H.IDHorario = he.IDHorario    
    and ((H.IDTurno = @IDTurnoInt) or (isnull(@IDTurno,0) = 0))  
 ,(Select * from Asistencia.tblCatTiposChecadas where Activo = 1 and IDTipoChecada <> 'SH') as TCH
GO
