USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [App].[spUConfiguraciones](  
    @IDConfiguracion varchar(255) = null  
    ,@Valor Varchar(max)
)   
as  

	update [App].[tblconfiguracionesGenerales]
	set valor = isnull(@Valor,'')
	where IDConfiguracion = @IDConfiguracion

	exec [App].[spBuscarConfiguraciones] @IDConfiguracion = @IDConfiguracion
GO
