USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar las Afores>
** Autor			: <Jose Rafael Roman Gil>
** Email			: <jose.roman@adagio.com.mx>
** FechaCreacion	: <11/06/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [RH].[spUICatAfores]
(
	@IDAfore int = 0,
	@Descripcion Varchar(MAX),
	@IDUsuario int
)
AS
BEGIN

  
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	IF(@IDAfore = 0)
	BEGIN
		INSERT INTO RH.tblCatAfores(Descripcion)
		VALUES(upper(@Descripcion))
		
		SET @IDAfore = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatAfores] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDAfore = @IDAfore

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatAfores]','[RH].[spUICatAfores]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [RH].[tblCatAfores] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDAfore = @IDAfore

		UPDATE RH.tblCatAfores
			set Descripcion = upper(@Descripcion)
		Where IDAfore = @IDAfore

		select @NewJSON = a.JSON from [RH].[tblCatAfores] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDAfore = @IDAfore

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatAfores]','[RH].[spUICatAfores]','UPDATE',@NewJSON,@OldJSON
	END
	
	SELECT IDAfore,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDAfore)as ROWNUMBER
	FROM RH.tblCatAfores
	Where IDAfore = @IDAfore
END
GO
