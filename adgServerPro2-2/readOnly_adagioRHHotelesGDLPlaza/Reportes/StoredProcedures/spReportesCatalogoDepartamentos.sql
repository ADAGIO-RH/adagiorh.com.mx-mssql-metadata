USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReportesCatalogoDepartamentos]  
(      
     @dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int            
)      
AS      
BEGIN      
       
 SELECT d.IDDepartamento,
       d.Codigo,
	   d.Descripcion,
	   d.CuentaContable,
	   d.IDEmpleado,
	   d.JefeDepartamento
FROM rh.tblCatDepartamentos d with (nolock)
ORDER BY d.Codigo, Descripcion
      
END
GO
