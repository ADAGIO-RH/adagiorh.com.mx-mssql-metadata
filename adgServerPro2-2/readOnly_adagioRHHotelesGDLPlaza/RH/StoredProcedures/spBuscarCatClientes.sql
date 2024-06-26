USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatClientes] --2    
(    
 @IDCliente int = null   
 ,@IDUsuario int = null   
)    
AS    
BEGIN    
	SET FMTONLY OFF;  

	IF OBJECT_ID('tempdb..#TempClientes') IS NOT NULL  
	DROP TABLE #TempClientes  
    
	select ID   
	Into #TempClientes  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Clientes'  
  
	SELECT     
		C.IDCliente    
		,cast(isnull(C.GenerarNoNomina,0) as bit) as GenerarNoNomina    
		,isnull(C.LongitudNoNomina,0) as LongitudNoNomina    
		,isnull(C.Prefijo,'') as Prefijo    
		,isnull(C.NombreComercial,'') as NombreComercial    
		,ISNULL(C.Codigo,'') as Codigo    
		,ISNULL(C.PathReciboNomina,'') as PathReciboNomina   
	FROM RH.[tblCatClientes] C  with(nolock)   
	WHERE (c.IDCliente = @IDCliente ) OR (@IDCliente is null)    
		and (IDCliente in  ( select ID from #TempClientes)  
		OR Not Exists(select ID from #TempClientes))  
	ORDER BY C.NombreComercial ASC    
END
GO
