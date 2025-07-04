USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [AzureCognitiveServices].[spIUPersonGroup](
	@PersonGroupId varchar(255),
	@Name varchar(255),
	@TotalPersons int = 0
) as
	if exists (select top 1 1 
				from [AzureCognitiveServices].[tblPersonsGroups] with (nolock)
				where PersonGroupId = @PersonGroupId)
	begin
		update [AzureCognitiveServices].[tblPersonsGroups]
			set [Name] = @Name,
				TotalPersons = @TotalPersons
		where PersonGroupId = @PersonGroupId
	end else
	begin
		insert [AzureCognitiveServices].[tblPersonsGroups](PersonGroupId, [Name], TotalPersons)
		select @PersonGroupId, @Name, @TotalPersons
	end
GO
