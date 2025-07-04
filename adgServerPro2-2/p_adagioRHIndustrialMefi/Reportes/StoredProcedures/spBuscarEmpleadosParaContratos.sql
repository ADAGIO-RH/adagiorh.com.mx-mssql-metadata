USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure Reportes.spBuscarEmpleadosParaContratos --@IDPeriodo = 1  
(  
  
 @IDCliente int = 0,   
 @IDPeriodo int = 0,   
 @EmpleadoIni Varchar(20) = '0',      
 @EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',      
 @dtDepartamentos Varchar(max) = '',  
 @dtSucursales Varchar(max) = '',  
 @dtPuestos Varchar(max) = '',  
 @dtTiposContratacion Varchar(max) = ''  
)  
AS  
BEGIN  
   
 Declare @dtFiltros [Nomina].[dtFiltrosRH],  
   @FechaIni Date,  
   @FechaFin Date,  
   @IDTipoNomina int  
  if(@IDPeriodo <> 0)  
  BEGIN  
  
   select @FechaIni = FechaInicioPago,  
       @FechaFin = FechaFinPago,  
       @IDTipoNomina = IDTipoNomina  
   from Nomina.tblCatPeriodos  
   where IDPeriodo = @IDPeriodo  
  END  
  ELSE  
  BEGIN  
   select @FechaIni = '1900-01-01',  
       @FechaFin = '9999-12-31',  
      @IDTipoNomina = 0   
  END  
  
 insert into @dtFiltros(Catalogo,Value)  
 values('Departamentos',@dtDepartamentos)  
  
 insert into @dtFiltros(Catalogo,Value)  
 values('Sucursales',@dtSucursales)  
   
 insert into @dtFiltros(Catalogo,Value)  
 values('Puestos',@dtPuestos)  

 insert into @dtFiltros(Catalogo,Value)  
 values('Clientes',@IDCliente)   
 
  insert into @dtFiltros(Catalogo,Value)  
 values('TiposContratacion',@dtTiposContratacion)      
  
 Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros  
  
END
GO
