USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatCentroCosto](
	@IDCentroCosto int = 0,
	@Codigo varchar(20),
	@Descripcion Varchar(50),
	@CuentaContable varchar(50),
	@ConfiguracionEventoCalendario varchar(max) = null,
	@IDUsuario int,
    @Traduccion nvarchar(max)
)
AS
BEGIN
	
	SET @Codigo         = UPPER(@Codigo)
	SET @Descripcion	= UPPER(@Descripcion)
	SET @CuentaContable	= UPPER(@CuentaContable)

	if (isnull(@ConfiguracionEventoCalendario, '') = '') 
	begin
		set @ConfiguracionEventoCalendario = '{ "BackgroundColor": "#9999ff", "Color": "#ffffff" }'
	end

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	IF(@IDCentroCosto = 0 OR @IDCentroCosto Is null)
	BEGIN

	IF EXISTS(Select Top 1 1 from RH.[tblCatCentroCosto] where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [RH].[tblCatCentroCosto](
			[Codigo]
			,[Descripcion]
			,[CuentaContable]
			,ConfiguracionEventoCalendario
            ,Traduccion
		)
		VALUES (
			@Codigo
			,@Descripcion
			,@CuentaContable
			,@ConfiguracionEventoCalendario
			,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end

		)
		SET @IDCentroCosto = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatCentroCosto] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCentroCosto=@IDCentroCosto;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatCentroCosto]','[RH].[spIUCatCentroCosto]','INSERT',@NewJSON,''

		exec RH.spBuscarCatCentroCosto @IDCentroCosto=@IDCentroCosto,@IDUsuario=@IDUsuario
	END
	ELSE
	BEGIN	
		IF EXISTS(Select Top 1 1 from RH.[tblCatCentroCosto] where Codigo = @Codigo and IDCentroCosto <> @IDCentroCosto)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON from [RH].[tblCatCentroCosto] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCentroCosto=@IDCentroCosto;

		UPDATE [RH].[tblCatCentroCosto]
		   SET [Codigo] = @Codigo
			  ,[Descripcion] = @Descripcion
			  ,[CuentaContable] = @CuentaContable
			  ,ConfiguracionEventoCalendario = @ConfiguracionEventoCalendario,
               Traduccion			= case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		 WHERE [IDCentroCosto]= @IDCentroCosto

		 select @NewJSON = a.JSON from [RH].[tblCatCentroCosto] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCentroCosto=@IDCentroCosto;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatCentroCosto]','[RH].[spIUCatCentroCosto]','UPDATE',@NewJSON,@OldJSON

		exec RH.spBuscarCatCentroCosto @IDCentroCosto=@IDCentroCosto,@IDUsuario=@IDUsuario
	END
END
GO
