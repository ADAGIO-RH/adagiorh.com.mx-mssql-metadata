USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReporteInfonavit] --@IDPeriodo = 1      
(      
  @FechaIni Date = '1900-01-01',      
  @FechaFin Date = '9999-12-31',      
  @IncluirNoVigentes bit = 0,      
  @IncluirInfonavitTerminados bit = 0,      
  @IDCliente int = 0,      
  @IDTipoNomina int = 0,      
 @dtDepartamentos Varchar(max) = '',      
 @dtSucursales Varchar(max) = '',      
 @dtPuestos Varchar(max) = '',      
 @dtRazonSociales Varchar(max) = '',      
 @dtRegPatronales Varchar(max) = '',      
 @dtDivisiones Varchar(max) = '',
 @IDUsuario int = null  
     
       
)      
AS      
BEGIN      
       
  SET FMTONLY OFF;  
  
 Declare @dtFiltros [Nomina].[dtFiltrosRH],      
   @empleados [RH].[dtEmpleados],  
   @SalarioMinimo Decimal(18,4),  
   @UMA  Decimal(18,4),     
   @FactorDescuento Decimal(18,4)  
  
  
  
   select top 1 @SalarioMinimo = SalarioMinimo  
  , @UMA = UMA  
  ,@FactorDescuento = FactorDescuento  
    from Nomina.tblSalariosMinimos   
 ORDER BY Fecha desc  
      
      
 set @FechaIni = case when @IncluirNoVigentes = 1 then  '1900-01-01' else isnull(@FechaIni,'1900-01-01') end      
 set @FechaFin = case when @IncluirNoVigentes = 1 then  '9999-12-31' else isnull(@FechaFin,'9999-12-31') end      
        
  --select @FechaIni, @FechaFin, @dtDepartamentos,@IDTipoNomina    
    
 -- set @IDTipoNomina  = ISNULL(@IDTipoNomina,0)    
    
 insert into @dtFiltros(Catalogo,Value)      
 values('Departamentos',@dtDepartamentos)      
      
 insert into @dtFiltros(Catalogo,Value)      
 values('Sucursales',@dtSucursales)      
       
 insert into @dtFiltros(Catalogo,Value)      
 values('Puestos',@dtPuestos)      
       
 insert into @dtFiltros(Catalogo,Value)      
 values('RazonesSociales',@dtRazonSociales)      
       
 insert into @dtFiltros(Catalogo,Value)      
 values('RegPatronales',@dtRegPatronales)       
      
 insert into @dtFiltros(Catalogo,Value)      
 values('Divisiones',@dtDivisiones)       
      
 insert into @dtFiltros(Catalogo,Value)      
 values('Clientes',case when @IDCliente = 0 then '' else cast( @IDCliente as varchar(max)) END)       
    
-- select * from @dtFiltros    
    
 insert into @empleados      
 Exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario     
      
    
IF OBJECT_ID('tempdb..#tempCreditos') IS NOT NULL  
    DROP TABLE #tempCreditos  
  
  
  --select * from @empleados    
 SELECT       
  IE.IDInfonavitEmpleado      
  ,IE.IDEmpleado      
  ,E.ClaveEmpleado      
  ,substring(UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,49 ) as NombreCompleto      
  ,ISNULL(IE.IDRegPatronal,0) as IDRegPatronal      
  ,RegPatronal.RegistroPatronal      
  ,RegPatronal.RazonSocial  
  ,e.Departamento      
  ,e.Puesto      
  ,IE.NumeroCredito      
  ,ISNULL(IE.IDTipoMovimiento,0) as IDTipoMovimiento      
  ,TipoMovimiento.Descripcion as TipoMovimiento      
  ,IE.Fecha      
  ,ISNULL(IE.IDTipoDescuento,0) as IDTipoDescuento      
  ,TipoDescuento.Descripcion as TipoDescuento      
  ,IE.ValorDescuento      
  ,ISNULL(IE.AplicaDisminucion,0) as  AplicaDisminucion  
  ,CASE WHEN TipoDescuento.Descripcion = 'Porcentaje'   THEN  (((E.SalarioIntegrado/100) * IE.ValorDescuento) * 30.4)  
  WHEN TipoDescuento.Descripcion = 'Factor de Descuento'   THEN (((@UMA/100) * IE.ValorDescuento) * 30.4)  
  WHEN TipoDescuento.Descripcion = 'Cuota Fija Monetaria'   THEN IE.ValorDescuento  
 ELSE IE.ValorDescuento  
 END as DescuentoMensual  
  into #tempCreditos   
 FROM RH.tblInfonavitEmpleado IE       
  INNER JOIN @empleados E      
   on IE.IDEmpleado = E.IDEmpleado      
  INNER JOIN RH.tblCatRegPatronal RegPatronal      
   on IE.IDRegPatronal = RegPatronal.IDRegPatronal      
  INNER JOIN RH.tblCatInfonavitTipoMovimiento TipoMovimiento      
   on TipoMovimiento.IDTipoMovimiento = IE.IDTipoMovimiento      
  INNER JOIN RH.tblCatInfonavitTipoDescuento TipoDescuento      
   on TipoDescuento.IDTipoDescuento = IE.IDTipoDescuento      
    
   
 if(@IncluirInfonavitTerminados = 0)  
 BEGIN  
  delete #tempCreditos  
  where TipoMovimiento = 'Fecha de Suspensión de Descuento (FS)'  
 END  
  
 select * from #tempCreditos  
      
END
GO
