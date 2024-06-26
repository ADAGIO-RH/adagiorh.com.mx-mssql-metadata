USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatClasificacionesCorporativas]  
(  
 @ClasificacionCorporativa Varchar(50) = null,
 @IDUsuario int = null  
)  
AS  
BEGIN 

	IF OBJECT_ID('tempdb..#TempClasificacionesCorporativas') IS NOT NULL
		DROP TABLE #TempClasificacionesCorporativas

	select ID 
	 Into #TempClasificacionesCorporativas
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'ClasificacionesCorporativas'

 
 Select  
 IDClasificacionCorporativa  
 ,Codigo  
 ,Descripcion  
 ,CuentaContable  
 ,ROW_NUMBER()over(ORDER BY IDClasificacionCorporativa)as ROWNUMBER  
 From RH.tblCatClasificacionesCorporativas  with(nolock)  
 where (Codigo like @ClasificacionCorporativa+'%') OR(Descripcion like @ClasificacionCorporativa+'%') OR(@ClasificacionCorporativa is null)  
 and (IDClasificacionCorporativa in  ( select ID from #TempClasificacionesCorporativas)
	OR Not Exists(select ID from #TempClasificacionesCorporativas))
 order by Descripcion asc
 

   
END
GO
