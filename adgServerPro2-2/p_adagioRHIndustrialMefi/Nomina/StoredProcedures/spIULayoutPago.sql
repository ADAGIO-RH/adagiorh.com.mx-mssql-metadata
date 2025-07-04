USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Nomina].[spIULayoutPago](    
	@IDLayoutPago int =null    
	,@IDTipoLayout int     
	,@Descripcion varchar(255)    
	,@IDConcepto int =null    
	,@ImporteTotal int= null  
	,@IDConceptoFiniquito int =null    
	,@ImporteTotalFiniquito int= null  
	,@IDUsuario int    
)    
AS    
BEGIN      
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIULayoutPago]',
		@Tabla		varchar(max) = '[Nomina].[tblLayoutPago]',
		@Accion		varchar(20)	= ''
	;

	set @Descripcion = upper(@Descripcion)  
  
	if(@IDLayoutPago is null or @IDLayoutPago = 0)    
	BEGIN    
		insert into Nomina.tblLayoutPago(IDTipoLayout,Descripcion,IDConcepto,ImporteTotal,IDConceptoFiniquito,ImporteTotalFiniquito)    
		values(@IDTipoLayout,@Descripcion,@IDConcepto,case when @ImporteTotal = 0 then 1 else @ImporteTotal end,@IDConceptoFiniquito,case when @ImporteTotalFiniquito = 0 then 1 else @ImporteTotalFiniquito end)    
    
		set @IDLayoutPago = @@IDENTITY    
    
		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].tblLayoutPago b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDLayoutPago = @IDLayoutPago
	END    
	ELSE    
	BEGIN 
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].tblLayoutPago b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDLayoutPago = @IDLayoutPago

		update Nomina.tblLayoutPago    
			set 
				IDTipoLayout = @IDTipoLayout,    
				Descripcion = @Descripcion,    
				IDConcepto = @IDConcepto,    
				ImporteTotal = case when @ImporteTotal = 0 then 1 else @ImporteTotal end,
				IDConceptoFiniquito = @IDConceptoFiniquito,    
				ImporteTotalFiniquito = case when @ImporteTotalFiniquito = 0 then 1 else @ImporteTotalFiniquito end    
		where IDLayoutPago = @IDLayoutPago 
		
		select @NewJSON = a.JSON
		from [Nomina].tblLayoutPago b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDLayoutPago = @IDLayoutPago
	END
	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
    
	exec [Nomina].[spBuscarLayoutPago]  @IDLayoutPago;    
	exec [Nomina].[spUIParametrosLayoutPago] @IDLayoutPago,@IDUsuario;  
END
GO
