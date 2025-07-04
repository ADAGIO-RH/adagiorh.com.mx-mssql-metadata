USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReporteDatosExtra] --@IDPeriodo = 1    
(    
  @FechaIni Date = '1900-01-01',    
  @FechaFin Date = '9999-12-31',    
  @IncluirNoVigentes bit = 0,    
  @IDCliente int = 0,    
  @IDTipoNomina int = 0,    
 @dtDepartamentos Varchar(max) = '',    
 @dtSucursales Varchar(max) = '',    
 @dtPuestos Varchar(max) = '',    
 @dtRazonSociales Varchar(max) = '',    
 @dtRegPatronales Varchar(max) = '',    
 @dtDivisiones Varchar(max) = '' ,
 @IDUsuario int   
     
)    
AS    
BEGIN    
     
 Declare @dtFiltros [Nomina].[dtFiltrosRH],    
   @empleados [RH].[dtEmpleados]    
    
    
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
 Exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario    
    
  
  --select * from @empleados  
  
 select e.ClaveEmpleado,    
     e.NOMBRECOMPLETO as NombreCompleto,    
     e.Departamento,    
     e.Puesto,    
     e.Sucursal  
  ,DE.Descripcion as DatoExtra  
  ,DEE.Valor      
 from @empleados e    
 CROSS JOIN RH.tblCatDatosExtra DE  
 left join RH.tblDatosExtraEmpleados DEE  
  on DE.IDDatoExtra = DEE.IDDatoExtra  
  and E.IDEmpleado = DEE.IDEmpleado  
   
    
    
END
GO
