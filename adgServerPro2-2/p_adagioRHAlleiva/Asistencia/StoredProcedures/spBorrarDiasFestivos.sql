USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBorrarDiasFestivos]
(
	@IDDiasFestivo int,
	@IDUsuario int
)
AS
BEGIN

	 DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

		select @OldJSON = a.JSON from [Asistencia].[TblCatDiasFestivos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDiaFestivo = @IDDiasFestivo

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[TblCatDiasFestivos]','[Asistencia].[spBorrarDiasFestivos]','DELETE','',@OldJSON
		


		--EXEC Asistencia.spBuscarDiasFestivos @IDDiasFestivo
	
		DELETE Asistencia.TblCatDiasFestivos
		WHERE IDDiaFestivo = @IDDiasFestivo
END
GO
