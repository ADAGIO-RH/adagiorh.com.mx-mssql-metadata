USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReportesCatalogoPuestos]  
(      
    @dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int           
)      
AS      
BEGIN      
       
SELECT p.IDPuesto,
       p.Codigo,
	   p.Descripcion,
	   p.DescripcionPuesto,
	   p.SueldoBase,
	   p.TopeSalarial,
	   p.NivelSalarial,
	   p.IDOcupacion
 FROM rh.tblCatPuestos p with (nolock)
 ORDER BY p.Codigo,Descripcion
      
END
GO
