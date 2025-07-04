USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUIConfiguracionNomina](  
	@IDConfiguracionNomina int  
	,@Configuracion VARCHAR(100)  
	,@Valor VARCHAR(255)  
	,@TipoDato VARCHAR(50)  
	,@Descripcion VARCHAR(500)  
	,@IDUsuario int
)  
AS  
BEGIN  
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUIConfiguracionNomina]',
		@Tabla		varchar(max) = '[Nomina].[tblConfiguracionNomina]',
		@Accion		varchar(20)	= ''
	;

	select 
		@Configuracion  = UPPER(@Configuracion)  
		,@Valor			= UPPER(@Valor)  
		,@TipoDato		= UPPER(@TipoDato)  
		,@Descripcion	= UPPER(@Descripcion)  
   
	IF((@IDConfiguracionNomina IS  NULL) OR (@IDConfiguracionNomina = 0))  
	BEGIN  
		INSERT INTO [Nomina].[tblConfiguracionNomina](Configuracion,Valor,TipoDato,Descripcion)  
		VALUES(@Configuracion,@Valor,@TipoDato,@Descripcion)  

		SET @IDConfiguracionNomina = @@IDENTITY  

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblConfiguracionNomina] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDConfiguracionNomina = @IDConfiguracionNomina
	END  
	ELSE  
	BEGIN  
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].[tblConfiguracionNomina] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDConfiguracionNomina = @IDConfiguracionNomina

		UPDATE [Nomina].[tblConfiguracionNomina]  
			SET Configuracion = @Configuracion  
			,Valor = @Valor  
			,TipoDato = @TipoDato  
			,Descripcion = @Descripcion  
		WHERE IDConfiguracionNomina = @IDConfiguracionNomina  
  
		select @NewJSON = a.JSON
		from [Nomina].[tblConfiguracionNomina] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDConfiguracionNomina = @IDConfiguracionNomina
	END  
  
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

	select   
		IDConfiguracionNomina  
		,Configuracion  
		,Valor  
		,TipoDato  
		,Descripcion   
		,ROW_NUMBER()over(ORDER BY IDConfiguracionNomina) as ROWNUMBER  
	From [Nomina].[tblConfiguracionNomina]  
	where IDConfiguracionNomina = @IDConfiguracionNomina  
  
END
GO
