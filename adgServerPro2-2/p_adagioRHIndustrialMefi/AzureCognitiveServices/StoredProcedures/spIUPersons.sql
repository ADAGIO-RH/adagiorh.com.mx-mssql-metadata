USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [AzureCognitiveServices].[spIUPersons](
	@PersonId varchar(255),
	@PersonGroupId varchar(255),
	@Name varchar(255),
	@UserData varchar(255), -- @UserData = {ClaveEmpleado}
	@IDEmpleado int
) as
	if exists (select top 1 1 
				from [AzureCognitiveServices].[tblPersons] with (nolock)
				where IDEmpleado = @IDEmpleado)
	begin
		update [AzureCognitiveServices].[tblPersons]
			set PersonGroupId = @PersonGroupId,
				[Name] = @Name,
				UserData = @UserData
		where PersonId = @PersonId
	end else
	begin
		insert [AzureCognitiveServices].[tblPersons](PersonId, PersonGroupId, [Name], UserData, IDEmpleado)
		select @PersonId,@PersonGroupId, @Name, @UserData,@IDEmpleado
	end;
GO
