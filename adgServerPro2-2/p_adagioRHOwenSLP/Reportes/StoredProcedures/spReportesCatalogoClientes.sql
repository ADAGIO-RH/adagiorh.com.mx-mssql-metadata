USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReportesCatalogoClientes]  
(      
     @dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int            
)      
AS      
BEGIN      
       
 SELECT c.IDCliente,      
		c.Prefijo,
		c.NombreComercial,
		c.Codigo,
		c.GenerarNoNomina,
		c.LongitudNoNomina
FROM rh.tblCatClientes c with (nolock)
ORDER BY c.NombreComercial
      
END
GO
