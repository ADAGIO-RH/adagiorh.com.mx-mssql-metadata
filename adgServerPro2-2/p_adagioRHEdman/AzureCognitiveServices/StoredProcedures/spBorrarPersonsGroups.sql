USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [AzureCognitiveServices].[spBorrarPersonsGroups](
	@PersonGroupId varchar(255)
) as
	delete [AzureCognitiveServices].[tblPersonsGroups]
	where PersonGroupId = @PersonGroupId
GO
