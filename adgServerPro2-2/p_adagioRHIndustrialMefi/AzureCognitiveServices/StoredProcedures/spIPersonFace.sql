USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [AzureCognitiveServices].[spIPersonFace](
	@PersonId varchar(255)	
	,@FaceId  varchar(255)	
	,@IDUsuario int
) as
	declare
		@Mensaje varchar(200)
	;

	begin try
		insert [AzureCognitiveServices].[tblPersonsFaces](PersonId, FaceId)
		values (@PersonId, @FaceId)
	end try
	begin catch
		select
			@Mensaje = ERROR_MESSAGE()

		exec [Log].[spILogHistory]
			@LogLevel = 'error'
			,@Mensaje = @Mensaje
			,@IDSource = 'stored-procedure'
			,@IDCategory = 'API'
			,@IDUsuario=@IDUsuario
			
	end catch
GO
