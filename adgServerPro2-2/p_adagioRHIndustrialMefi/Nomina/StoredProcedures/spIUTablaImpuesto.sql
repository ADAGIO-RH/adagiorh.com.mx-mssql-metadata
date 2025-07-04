USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Nomina].[spIUTablaImpuesto]
(
	 @IDTablaImpuesto int = 0
	,@IDPeriodicidadPago int
	,@Ejercicio int
	,@IDCalculo int
	,@Descripcion varchar(255)
	,@IDPais int = null
	,@IDUsuario int
) as
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUTablaImpuesto]',
		@Tabla		varchar(max) = '[Nomina].[tblTablasImpuestos]',
		@Accion		varchar(20)	= ''
	;

	SET @Descripcion = UPPER(@Descripcion)
    if (@IDTablaImpuesto = 0 or @IDTablaImpuesto is null)
	begin
		insert into [Nomina].[tblTablasImpuestos] (IDPeriodicidadPago,Ejercicio,IDCalculo,Descripcion, IDPais)
		select @IDPeriodicidadPago,@Ejercicio,@IDCalculo,@Descripcion, CASE WHEN ISNULL(@IDPais,0) = 0 THEN NULL ELSE @IDPais END

		select @IDTablaImpuesto=@@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblTablasImpuestos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTablaImpuesto = @IDTablaImpuesto
    end else
    begin
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].[tblTablasImpuestos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTablaImpuesto = @IDTablaImpuesto

		update [Nomina].[tblTablasImpuestos]
		set IDPeriodicidadPago = @IDPeriodicidadPago
			,Ejercicio	  = @Ejercicio
			,IDCalculo	  = @IDCalculo
			,Descripcion	  = @Descripcion
			,IDPais			= CASE WHEN ISNULL(@IDPais,0) = 0 THEN NULL ELSE @IDPais END
		where IDTablaImpuesto = @IDTablaImpuesto

		select @NewJSON = a.JSON
		from [Nomina].[tblTablasImpuestos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTablaImpuesto = @IDTablaImpuesto
    end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

    exec [Nomina].[spBuscarTablasImpuesto] @IDTablaImpuesto=@IDTablaImpuesto
END;
GO
