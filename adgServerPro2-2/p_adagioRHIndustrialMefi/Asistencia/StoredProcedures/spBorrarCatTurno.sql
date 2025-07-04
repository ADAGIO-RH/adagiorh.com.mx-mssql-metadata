USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBorrarCatTurno]
(
 @IDTurno int
 ,@IDUsuario int
)
as
BEGIN

 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Asistencia].[tblCatTurnos] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDTurno = @IDTurno

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatTurnos]','[Asistencia].[spBorrarCatTurno]','DELETE','',@OldJSON
		


    BEGIN TRY  
	    DELETE [Asistencia].[tblCatTurnos] 
	    WHERE IDTurno = @IDTurno
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
