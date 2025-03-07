USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spBorrarCatPeriodos]
(
	 @IDPeriodo int,
	 @IDUsuario int 
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarCatPeriodos]',
		@Tabla		varchar(max) = '[Nomina].[tblCatPeriodos]',
		@Accion		varchar(20)	= 'DELETE',
		@CustomMessage varchar(max),
        @Presupuesto bit 
	;

	select @OldJSON = a.JSON 
    ,@Presupuesto = ISNULL(b.Presupuesto,0)
	from [Nomina].[tblcatPeriodos] b with (nolock)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE  IDPeriodo = @IDPeriodo

	exec Nomina.spBuscarCatPeriodos @IDPeriodo = @IDPeriodo,@Presupuesto = @Presupuesto, @IDUsuario = @IDUsuario

	BEGIN TRY  
		Delete Nomina.tblDetallePeriodo
		where IDPeriodo = @IDPeriodo

        Delete Nomina.tblDetallePeriodoPresupuesto
		where IDPeriodo = @IDPeriodo
	
		Delete Nomina.tblDetallePeriodoFiniquito
		where IDPeriodo = @IDPeriodo

		Delete Nomina.tblHistorialesEmpleadosPeriodos
		where IDPeriodo = @IDPeriodo

		Delete Nomina.tblCatPeriodos
		where IDPeriodo = @IDPeriodo
        
    END TRY  
    BEGIN CATCH  
		set @CustomMessage = ERROR_MESSAGE()

		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002',@CustomMessage=@CustomMessage
		return 0;
    END CATCH ;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
