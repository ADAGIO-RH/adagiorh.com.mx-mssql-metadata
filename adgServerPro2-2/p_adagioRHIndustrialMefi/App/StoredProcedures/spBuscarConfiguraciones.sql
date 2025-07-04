USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [App].[spBuscarConfiguraciones](  
    @IDConfiguracion varchar(255) = null  
    ,@IDTipoConfiguracionGeneral int = null  
)   
as  
	select cg.IDConfiguracion  
		,cg.Valor  
		,cg.TipoValor  
		,cg.Descripcion  
		,isnull(cg.IDTipoConfiguracionGeneral,0) as IDTipoConfiguracionGeneral  
		,tcg.Tipo as TipoConfiguracion
		,tcg.Descripcion as DescripcionTipoConfiguracion
		,cg.[Data]
		,ROW_NUMBER()Over(Order by cg.IDTipoConfiguracionGeneral asc) as ROWNUMBER 
	from [App].[tblconfiguracionesGenerales] cg  
		join [App].[tblTipoConfiguracionGeneral] tcg with (nolock) on cg.IDTipoConfiguracionGeneral = tcg.IDTipoConfiguracionGeneral  
	where ((IDConfiguracion = @IDConfiguracion) or (@IDConfiguracion is null))  
		   AND ((cg.IDTipoConfiguracionGeneral = @IDTipoConfiguracionGeneral) or (@IDTipoConfiguracionGeneral is null))  
	order by cg.IDTipoConfiguracionGeneral
GO
