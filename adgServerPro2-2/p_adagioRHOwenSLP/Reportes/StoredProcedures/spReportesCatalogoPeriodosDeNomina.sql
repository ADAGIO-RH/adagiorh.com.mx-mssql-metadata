USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReportesCatalogoPeriodosDeNomina]  
(      
     @dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int            
)      
AS      
BEGIN      
       

 select  
         cl.Codigo as [CODIGO]
        ,cl.NombreComercial as [CLIENTE]
		,ctn.Descripcion AS [TIPO NOMINA]
		,cp.IDPeriodo AS [ID PERIODO]
		,cp.Ejercicio AS [EJERCICIO]
		,cp.ClavePeriodo AS [CLAVEPERIODO]
         , cp.Descripcion AS [DESCRIPCION]
		 ,FORMAT(cp.FechaInicioPago,'dd/MM/yyyy')  as [FECHA INICIO PAGO]
		 ,FORMAT(cp.FechaFinPago,'dd/MM/yyyy')  as [FECHA FIN PAGO]
		 ,FORMAT(cp.FechaInicioIncidencia,'dd/MM/yyyy')  as [FECHA INICIO INCIDENCIA]
		 ,FORMAT(cp.FechaFinIncidencia,'dd/MM/yyyy')  as [FECHA FIN INCIDENCIA]		
		  ,cp.Dias as [DIAS]
		  ,cp.AnioInicio as [AÑO INICIO]
		  ,cp.AnioFin as [AÑO FIN]
		  ,cp.MesInicio as [MES INICIO]
		  ,cp.MesFin as [MES FIN]
		  ,cp.IDMes as [IDMes]
		  ,cp.BimestreInicio as [BIMESTRE INICIO]
		  ,cp.BimestreFin as [BIMESTRE FIN]
		  ,cp.Cerrado as [CERRADO]
		  ,cp.General as [GENERAL]
		  ,cp.Finiquito as [FINIQUITO]
		  ,cp.Especial as [ESPECIAL]		  
 from nomina.tblCatPeriodos cp with (nolock)
 inner join nomina.tblCatTipoNomina ctn with (nolock) on  ctn.IDTipoNomina = cp.IDTipoNomina
 inner join rh.tblCatClientes cl with (nolock) on cl.IDCliente = ctn.IDCliente
 WHERE ((CL.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
				or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>''))) 
  and((CTN.IDTipoNomina in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')))             
				or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoNomina' and isnull(Value,'')<>''))) 	
   and((cp.Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')))             
				or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Ejercicio' and isnull(Value,'')<>''))) 				

 ORDER BY cl.NombreComercial,ctn.Descripcion,cp.Ejercicio, cp.FechaInicioPago
      
END
GO
