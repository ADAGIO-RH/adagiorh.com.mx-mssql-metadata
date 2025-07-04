USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Reclutamiento].[spBuscarActivationKey](    
	@key varchar(255)    
) as   
	
	select     
		 aKey.IDCandidato
		,aKey.Nombre
		,aKey.SegundoNombre
		,aKey.Paterno
		,aKey.Materno
		,aKey.AvaibleUntil
	from Reclutamiento.tblCandidatos aKey    
	where aKey.ActivationKey = @key    
		and (aKey.AvaibleUntil >= cast(getdate() as date))
GO
