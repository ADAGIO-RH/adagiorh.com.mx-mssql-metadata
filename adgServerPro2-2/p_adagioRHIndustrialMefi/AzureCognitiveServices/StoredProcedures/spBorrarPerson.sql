USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [AzureCognitiveServices].[spBorrarPerson](
	@PersonId varchar(255)
) as
	delete [AzureCognitiveServices].[tblPersons]
	where PersonId = @PersonId
GO
