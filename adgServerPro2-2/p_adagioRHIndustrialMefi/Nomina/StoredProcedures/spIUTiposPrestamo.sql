USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUTiposPrestamo](  
	@IDTipoPrestamo int = 0,  
	@Codigo varchar(20),  
	@Descripcion Varchar(100),  
	@IDConcepto int,
	@Intranet bit = 0,
	@IDUsuario int ,
    @Traduccion nvarchar(max)
)  
AS  
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUTiposPrestamo]',
		@Tabla		varchar(max) = '[Nomina].[tblCatTiposPrestamo]',
		@Accion		varchar(20)	= ''
	;

	SET @Codigo = UPPER(@Codigo)  
	SET @Descripcion = UPPER(@Descripcion)  
  
	IF(@IDTipoPrestamo = 0 or @IDTipoPrestamo is null)  
	BEGIN  
		insert into Nomina.tblCatTiposPrestamo(Codigo,Descripcion,IDConcepto,Intranet, Traduccion)  
		VALUES(@Codigo,@Descripcion,@IDConcepto, @Intranet,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end)  
    
		SET @IDTipoPrestamo = @@IDENTITY 
		
		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].tblCatTiposPrestamo b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTipoPrestamo = @IDTipoPrestamo
	END  
	ELSE  
	BEGIN
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].tblCatTiposPrestamo b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTipoPrestamo = @IDTipoPrestamo

		UPDATE Nomina.tblCatTiposPrestamo  
			set Codigo			= @Codigo  
				,Descripcion	= @Descripcion  
				,IDConcepto		= @IDConcepto  
				,Intranet		= @Intranet
                ,Traduccion     = case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		WHERE IDTipoPrestamo = @IDTipoPrestamo 
		
		select @NewJSON = a.JSON
		from [Nomina].tblCatTiposPrestamo b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTipoPrestamo = @IDTipoPrestamo
	END
	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
	
	exec [Nomina].[spBuscarTiposPrestamo] @IDTipoPrestamo=@IDTipoPrestamo
END
GO
