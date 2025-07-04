USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUConfigISN](
	@IDConfigISN int
	,@IDEstado int
	,@Porcentaje decimal(10,4)
	,@IDConceptos Varchar(max)
	,@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUConfigISN]',
		@Tabla		varchar(max) = '[Nomina].[tblConfigISN]',
		@Accion		varchar(20)	= 'UPDATE'
	;

	select @OldJSON = a.JSON 
	from [Nomina].[tblConfigISN] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDConfigISN = @IDConfigISN

	UPDATE [Nomina].[tblConfigISN]
	SET 
		Porcentaje = @Porcentaje,
		IDConceptos= @IDConceptos
	WHERE [IDConfigISN] = @IDConfigISN and IDEstado = @IDEstado

	select @NewJSON = a.JSON 
	from [Nomina].[tblConfigISN] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDConfigISN = @IDConfigISN

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
