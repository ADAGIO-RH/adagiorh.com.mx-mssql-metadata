USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [AzureCognitiveServices].[spBuscarPersonsGroups](
	@PersonGroupId varchar(255) = null
) as
	select 
		PersonGroupId
		,[Name]		
		,isnull(TotalPersons,0) as TotalPersons 
		,isnull(CreationTime,getdate()) as CreationTime
	from [AzureCognitiveServices].[tblPersonsGroups] with (nolock)
	where PersonGroupId = @PersonGroupId or @PersonGroupId is null
GO
