USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spBorrarConfiguracionNomina]
(
	@IDConfiguracionNomina int
	,@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarConfiguracionNomina]',
		@Tabla		varchar(max) = '[Nomina].[tblConfiguracionNomina]',
		@Accion		varchar(20)	= 'DELETE'

	select @OldJSON = a.JSON 
	from [Nomina].[tblConfiguracionNomina] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE  IDConfiguracionNomina = @IDConfiguracionNomina

	select 
		IDConfiguracionNomina
		,Configuracion
		,Valor
		,TipoDato
		,Descripcion
		,ROW_NUMBER()over(ORDER BY IDConfiguracionNomina) as ROWNUMBER
	From [Nomina].[tblConfiguracionNomina]
	where IDConfiguracionNomina = @IDConfiguracionNomina
	
	DELETE [Nomina].[tblConfiguracionNomina]
	WHERE IDConfiguracionNomina = @IDConfiguracionNomina

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
