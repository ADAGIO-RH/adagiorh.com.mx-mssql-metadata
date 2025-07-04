USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatExpedientesDigitales]
(
	 @IDExpedienteDigital int = 0 
	,@Codigo Varchar(20)
	,@Descripcion Varchar(MAX) = null
	,@Requerido bit = 0
	,@IDCarpetaExpedienteDigital int = 0 
	,@IDUsuario int
    ,@Intranet int = 0
    ,@Reclutamiento int =0
	,@Caduca bit = 0
	,@IDPeriodicidad int = 0
	,@PeriodoVigenciaDocumento int = 0
	,@IntranetConfig NVARCHAR(MAX)
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	SET @Codigo = UPPER(@Codigo)
	SET @Descripcion = UPPER(@Descripcion)
	IF @Caduca = 0
		set @PeriodoVigenciaDocumento = null
		
    -- raiserror('No se encontró el registro para eliminar.', 16, 1);

	IF(@IDExpedienteDigital is null OR @IDExpedienteDigital = 0)
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatExpedientesDigitales] WITH(NOLOCK) where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO RH.tblCatExpedientesDigitales(Codigo,Descripcion,Requerido,IDCarpetaExpedienteDigital, Caduca, IDPeriodicidad, FechaHoraActualizacion, PeriodoVigenciaDocumento,Intranet,Reclutamiento,IntranetConfig)
		VALUES(@Codigo,@Descripcion,@Requerido,
			CASE WHEN ISNULL(@IDCarpetaExpedienteDigital,0) = 0 THEN (SELECT TOP 1 IDCarpetaExpedienteDigital from RH.tblCatCarpetasExpedienteDigital where Descripcion = 'OTROS' and Core = 1)
				ELSE @IDCarpetaExpedienteDigital
				END
			, @Caduca
			,  case when @IDPeriodicidad = 0 then null else @IDPeriodicidad end 
			, GETDATE()
			, @PeriodoVigenciaDocumento
            ,@Intranet
            ,@Reclutamiento
			,@IntranetConfig
		)
		
		SET @IDExpedienteDigital = @@IDENTITY

		SELECT @NewJSON = a.JSON 
		FROM [RH].[tblCatExpedientesDigitales] b WITH(NOLOCK)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigital = @IDExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatExpedientesDigitales]','[RH].[spIUCatExpedientesDigitales]','INSERT',@NewJSON,''


	END ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatExpedientesDigitales] WITH(NOLOCK) where Codigo = @Codigo and IDExpedienteDigital <> @IDExpedienteDigital)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
		
		SELECT @OldJSON = a.JSON from [RH].[tblCatExpedientesDigitales] b  WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigital = @IDExpedienteDigital

		UPDATE [RH].[tblCatExpedientesDigitales]
			SET Codigo = @Codigo
				, Descripcion = @Descripcion
				, Requerido = @Requerido
				, IDCarpetaExpedienteDigital = CASE WHEN ISNULL(@IDCarpetaExpedienteDigital,0) = 0 THEN (SELECT TOP 1 IDCarpetaExpedienteDigital from RH.tblCatCarpetasExpedienteDigital where Descripcion = 'OTROS' and Core = 1)
													ELSE @IDCarpetaExpedienteDigital
													END
				, Caduca = @Caduca
				, IDPeriodicidad = case when @IDPeriodicidad = 0 then null else @IDPeriodicidad end 
				, FechaHoraActualizacion = GETDATE()
				, PeriodoVigenciaDocumento = @PeriodoVigenciaDocumento
                , Reclutamiento=@Reclutamiento
                , Intranet=@Intranet
				, IntranetConfig = @IntranetConfig
		WHERE IDExpedienteDigital = @IDExpedienteDigital

		select @NewJSON = a.JSON from [RH].[tblCatExpedientesDigitales] b WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigital = @IDExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatExpedientesDigitales]','[RH].[spIUCatExpedientesDigitales]','UPDATE',@NewJSON,@OldJSON
	END

	EXEC [RH].[spBuscarCatExpedientesDigitales] @IDExpedienteDigital=@IDExpedienteDigital, @IDUsuario = @IDUsuario

END;
GO
