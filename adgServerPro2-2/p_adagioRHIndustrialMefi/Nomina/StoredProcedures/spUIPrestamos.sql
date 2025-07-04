USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUIPrestamos](  
	@IDPrestamo int = 0  OUTPUT
	,@Codigo varchar(20)  
	,@IDEmpleado int  
	,@IDTipoPrestamo int  
	,@IDEstatusPrestamo int  
	,@MontoPrestamo decimal(18,4)  
	,@Cuotas decimal(18,4)  
	,@CantidadCuotas int  
	,@Descripcion varchar(max)  
	,@FechaInicioPago date 
	,@Intereses decimal(18,2)    
	,@IDUsuario int 
)  
AS  
BEGIN
    
BEGIN TRY
	BEGIN TRAN TransPrestamos    
			declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUIPrestamos]',
		@Tabla		varchar(max) = '[Nomina].[tblPrestamos]',
		@Accion		varchar(20)	= ''
	;
   
	SET @Codigo = UPPER(@Codigo)   
	SET @Descripcion = UPPER(@Descripcion)  
  
	if(@IDPrestamo = 0 or @IDPrestamo is null)  
	BEGIN  
		insert into [Nomina].[tblPrestamos](IDEmpleado  
			,IDTipoPrestamo  
			,IDEstatusPrestamo  
			,MontoPrestamo  
			,Cuotas  
			,CantidadCuotas  
			,Descripcion  
			,FechaCreacion  
			,FechaInicioPago
			,Intereses)  
		Values(@IDEmpleado  
			,@IDTipoPrestamo  
			,@IDEstatusPrestamo  
			,@MontoPrestamo  
			,@Cuotas  
			,@CantidadCuotas  
			,@Descripcion  
			,getdate()  
			,@FechaInicioPago
			,isnull(@Intereses,0))  
	
		set @IDPrestamo = @@IDENTITY  
        
		UPDATE P  
			SET Codigo = COALESCE(E.ClaveEmpleado,'')+' - P'+ CAST(@IDPrestamo as varchar)  
		from [Nomina].[tblPrestamos] p  
			inner join [RH].[tblEmpleados] e on P.IDEmpleado = e.IDEmpleado  
		where p.IDPrestamo = @IDPrestamo
		
		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblPrestamos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE b.IDPrestamo = @IDPrestamo

	END  
	ELSE  
	BEGIN
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].[tblPrestamos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE b.IDPrestamo = @IDPrestamo

		UPDATE [Nomina].[tblPrestamos]  
			SET IDTipoPrestamo = @IDTipoPrestamo,  
			IDEstatusPrestamo = @IDEstatusPrestamo,  
			MontoPrestamo = @MontoPrestamo,  
			Cuotas = @Cuotas,  
			CantidadCuotas = @CantidadCuotas,  
			Descripcion = @Descripcion,  
			FechaInicioPago = @FechaInicioPago,
			Intereses = ISNULL(@Intereses,0)  
		WHERE IDPrestamo = @IDPrestamo  
		
		select @NewJSON = a.JSON
		from [Nomina].[tblPrestamos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE b.IDPrestamo = @IDPrestamo
	END  

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
  
	exec [Nomina].[spBuscarPrestamos] @IDPrestamo = @IDPrestamo , @IDUsuario  = @IDUsuario 
	

COMMIT TRAN TransPrestamos
END TRY
BEGIN CATCH
	ROLLBACK TRAN TransPrestamos
    declare @error varchar(max) = ERROR_MESSAGE();
    raiserror(@error, 16,1);
END CATCH

END
GO
