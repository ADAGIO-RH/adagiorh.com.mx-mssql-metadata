USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-09
-- Description:	sp para Eliminar plantillas
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBorrarPlantillas]
	(
		@IDPlantilla int
		,@IDUsuario int = 0
	)
AS
BEGIN
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from Reclutamiento.tblPlantillas b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDPlantilla = @IDPlantilla
			
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblPlantillas]','[Reclutamiento].[Reclutamiento].[spBorrarPlantillas]','DELETE','',@OldJSON

	DELETE FROM [Reclutamiento].[tblPlantillas]
		  WHERE IDPlantilla = @IDPlantilla

END
GO
