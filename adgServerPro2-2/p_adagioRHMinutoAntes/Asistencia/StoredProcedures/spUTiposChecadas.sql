USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA ACTIVAR/ DESACTIVAR LOS TIPOS DE CHECADAS
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spUTiposChecadas] 
(
	@IDTipoChecada Varchar(10) = NULL,
	@Activo bit ,
	@IDUsuario int
)
AS
BEGIN


 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Asistencia].[tblCatTiposChecadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoChecada = @IDTipoChecada

	UPDATE Asistencia.tblCatTiposChecadas
		set Activo = @Activo
	WHERE IDTipoChecada = @IDTipoChecada

	select @NewJSON = a.JSON from [Asistencia].[tblCatTiposChecadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoChecada = @IDTipoChecada

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatTiposChecadas]','[Asistencia].[spUTiposChecadas]','UPDATE',@NewJSON,@OldJSON
		

EXEC Asistencia.spBuscarTiposChecadas @IDTipoChecada
END
GO
