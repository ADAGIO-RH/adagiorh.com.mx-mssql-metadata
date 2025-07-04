USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodo]
(
	@IDEmpleado	int
	,@IDPeriodo int
	,@IDConcepto int
	,@CantidadMonto decimal(9,4)
	,@CantidadDias decimal(9,4)
	,@CantidadVeces decimal(9,4)
	,@CantidadOtro1 decimal(9,4)
	,@CantidadOtro2 decimal(9,4)
	,@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUICapturaDetallePeriodo]',
		@Tabla		varchar(max) = '[Nomina].[tblDetallePeriodo]',
		@Accion		varchar(20)	= ''
	;

	IF EXISTS(Select 1 
				from Nomina.tblDetallePeriodo 
				WHERE IDEmpleado = @IDEmpleado AND IDPeriodo = @IDPeriodo and IDConcepto = @IDConcepto)
	BEGIN
		select @OldJSON = a.JSON 
			,@Accion = 'UPDATE'
		from [Nomina].tblDetallePeriodo b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDEmpleado = @IDEmpleado AND IDPeriodo = @IDPeriodo AND IDConcepto = @IDConcepto

		UPDATE Nomina.tblDetallePeriodo
			set CantidadMonto  = @CantidadMonto
				,CantidadDias   = @CantidadDias 
				,CantidadVeces  = @CantidadVeces
				,CantidadOtro1  = @CantidadOtro1
				,CantidadOtro2  = @CantidadOtro2
		WHERE IDEmpleado = @IDEmpleado 
			AND IDPeriodo = @IDPeriodo 
			AND IDConcepto = @IDConcepto

		select @NewJSON = a.JSON 
		from [Nomina].tblDetallePeriodo b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDEmpleado = @IDEmpleado AND IDPeriodo = @IDPeriodo AND IDConcepto = @IDConcepto
	END
	ELSE
	BEGIN	
		INSERT INTO Nomina.tblDetallePeriodo(IDEmpleado
											,IDPeriodo
											,IDConcepto
											,CantidadMonto
											,CantidadDias
											,CantidadVeces
											,CantidadOtro1
											,CantidadOtro2)
		VALUES(@IDEmpleado
			,@IDPeriodo
			,@IDConcepto
			,@CantidadMonto
			,@CantidadDias
			,@CantidadVeces
			,@CantidadOtro1
			,@CantidadOtro2)
		
		select @NewJSON = a.JSON,
			@Accion = 'INSERT'
		from [Nomina].tblDetallePeriodo b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDEmpleado = @IDEmpleado AND IDPeriodo = @IDPeriodo AND IDConcepto = @IDConcepto
	END

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
