USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReportesCatalogoTiposNomina]  
(      
     @dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int            
)      
AS      
BEGIN      
       
 SELECT ctn.IDTipoNomina as  [ID TIPO NOMINA]
        ,ctn.Descripcion as [DESCRIPCION]
		,pg.Descripcion as [PERIODICIDAD PAGO]
		,cp.Descripcion as[PERIODO]
		,cl.NombreComercial as [CLIENTE]
		,cl.Prefijo  as [PREFIJO CLIENTE]
	
FROM nomina.tblCatTipoNomina ctn with (nolock)
 left join rh.tblCatClientes cl with (nolock) on cl.IDCliente = ctn.IDCliente
 left join sat.tblCatPeriodicidadesPago pg with (nolock) on pg.IDPeriodicidadPago = ctn.IDPeriodicidadPago
 left join nomina.tblCatPeriodos cp with (nolock) on cp.IDPeriodo = ctn.IDPeriodo
 ORDER BY cl.NombreComercial
      
END
GO
