USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [Nomina].[spIUCatTiposLayout](  
	@IDTipoLayout int = null  
	,@TipoLayout varchar(255)  
	,@IDBanco int = 0  
	--,@IDConcepto int = 0  
	,@NombreProcedimiento nvarchar(max) = ''  
	,@IDUsuario int  
)  
AS  
BEGIN 
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUCatTiposLayout]',
		@Tabla		varchar(max) = '[Nomina].[tblCatTiposLayout]',
		@Accion		varchar(20)	= ''

	SET @TipoLayout = UPPER(@TipoLayout)  
  
	IF(@IDTipoLayout = 0 or @IDTipoLayout is null)  
	BEGIN  
  
		IF EXISTS(Select Top 1 1 from Nomina.[tblCatTiposLayout] where TipoLayout = @TipoLayout)  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
			RETURN 0;  
		END  
  
		INSERT INTO Nomina.tblCatTiposLayout(TipoLayout,IDBanco,NombreProcedimiento)  
		values(@TipoLayout,@IDBanco,@NombreProcedimiento)  
  
		set @IDTipoLayout = @@IDENTITY  

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblCatTiposLayout] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDTipoLayout = @IDTipoLayout
	END  
	ELSE  
	BEGIN  
		IF EXISTS(Select Top 1 1 from Nomina.[tblCatTiposLayout] where TipoLayout = @TipoLayout and IDTipoLayout <> @IDTipoLayout)  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
			RETURN 0;  
		END  

		select @OldJSON = a.JSON 
			,@Accion = 'UPDATE'
		from [Nomina].[tblCatTiposLayout] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTipoLayout = @IDTipoLayout
  
		UPDATE Nomina.tblCatTiposLayout  
			SET 
				TipoLayout = @TipoLayout,  
				IDBanco = @IDBanco,  
				NombreProcedimiento = @NombreProcedimiento  
		WHERE IDTipoLayout = @IDTipoLayout  
		
		select @NewJSON = a.JSON
		from [Nomina].[tblCatTiposLayout] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTipoLayout = @IDTipoLayout
	END  

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

	SELECT  
		IDTipoLayout  
		,TipoLayout  
		,ISNULL(TL.IDBanco,0) as IDBanco  
		,B.Descripcion as Banco  
		,TL.NombreProcedimiento  
		,ROW_NUMBER()over(order by IDTipoLayout asc) as ROWNUMBER  
	FROM Nomina.tblCatTiposLayout TL  
		Left Join Sat.tblCatBancos B  
		on TL.IDBanco = B.IDBanco  
	WHERE (TL.IDTipoLayout = @IDTipoLayout)   
END
GO
