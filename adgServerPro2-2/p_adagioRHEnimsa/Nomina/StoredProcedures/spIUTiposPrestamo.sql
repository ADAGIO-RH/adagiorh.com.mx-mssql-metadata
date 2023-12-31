USE [p_adagioRHEnimsa]
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
	@IDUsuario int  
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
		insert into Nomina.tblCatTiposPrestamo(Codigo  
				,Descripcion  
				,IDConcepto)  
		VALUES(@Codigo,@Descripcion,@IDConcepto)  
    
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
			set  Codigo = @Codigo  
				,Descripcion = @Descripcion  
				,IDConcepto = @IDConcepto  
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
	
	SELECT p.IDTipoPrestamo  
		,p.Codigo  
		,p.Descripcion  
		,isnull(p.IDConcepto,0)as IDConcepto  
		,c.Codigo +' - '+ c.Descripcion as DescripcionConcepto  
		,ROW_NUMBER()over(ORDER BY P.IDTipoPrestamo)as ROWNUMBER  
	FROM Nomina.tblCatTiposPrestamo p   
		left join Nomina.tblCatConceptos c  
			on p.IDConcepto = c.IDConcepto  
	WHERE (IDTipoPrestamo = @IDTipoPrestamo) 
END
GO
