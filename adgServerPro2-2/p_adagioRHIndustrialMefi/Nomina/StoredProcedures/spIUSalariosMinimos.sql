USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [Nomina].[spIUSalariosMinimos](
	@IDSalarioMinimo int = 0 
	,@Fecha date
	,@SalarioMinimo decimal(9,2)
	,@SalarioMinimoFronterizo decimal(9,2)
	,@UMA decimal(9,2)    
	,@FactorDescuento decimal(9,2) 
	,@IDPais int
	,@AjustarUMI bit = 0
	,@TopeMensualSubsidioSalario decimal(18,2) = 0
	,@PorcentajeUMASubsidio decimal(18,2) = 0
	,@IDUsuario int
)
as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUSalariosMinimos]',
		@Tabla		varchar(max) = '[Nomina].[tblSalariosMinimos]',
		@Accion		varchar(20)	= ''
	;

	if (@IDSalarioMinimo is null or @IDSalarioMinimo = 0)
	begin
		insert into [Nomina].[tblSalariosMinimos](Fecha, SalarioMinimo,SalarioMinimoFronterizo,UMA,FactorDescuento,IDPais, AjustarUMI,TopeMensualSubsidioSalario, PorcentajeUMASubsidio)
		select @Fecha,@SalarioMinimo, @SalarioMinimoFronterizo,@UMA,@FactorDescuento, CASE WHEN ISNULL(@IDPais,0) = 0 THEN NULL ELSE @IDPais END,@AjustarUMI, ISNULL(@TopeMensualSubsidioSalario,0.00), isnull(@PorcentajeUMASubsidio,0.00)

		select @IDSalarioMinimo=@@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblSalariosMinimos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDSalarioMinimo = @IDSalarioMinimo
    end else
    begin
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].[tblSalariosMinimos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDSalarioMinimo = @IDSalarioMinimo

		update [Nomina].[tblSalariosMinimos]
			set Fecha = @Fecha
				,SalarioMinimo = @SalarioMinimo
				,SalarioMinimoFronterizo = @SalarioMinimoFronterizo
				,UMA = @UMA
				,FactorDescuento = @FactorDescuento
				,IDPais = CASE WHEN ISNULL(@IDPais,0) = 0 THEN NULL ELSE @IDPais END
				,AjustarUMI = @AjustarUMI
				,TopeMensualSubsidioSalario = ISNULL(@TopeMensualSubsidioSalario,0.00)
				,PorcentajeUMASubsidio = isnull(@PorcentajeUMASubsidio,0.00)
		where IDSalarioMinimo = @IDSalarioMinimo

		select @NewJSON = a.JSON
		from [Nomina].[tblSalariosMinimos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDSalarioMinimo = @IDSalarioMinimo
    end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
GO
