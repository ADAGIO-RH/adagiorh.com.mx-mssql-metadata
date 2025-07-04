USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc App.spBorrarDriverTour(
	@IDDriverTour varchar(255) = 0,
	@IDUsuario int
) as
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	select @OldJSON = a.JSON from App.tblDriversTours b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDDriverTour = @IDDriverTour

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[App].[tblDriversTours]','App.spBorrarDriverTour','DELETE','',@OldJSON
	
    BEGIN TRY  
		DELETE App.tblDriversTours
		WHERE IDDriverTour = @IDDriverTour
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
