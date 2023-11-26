USE [p_adagioRHCRHIrkon]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spIUCatTiposPrestaciones]
(
	@IDTipoPrestacion int = 0
	,@Codigo varchar(20)
	,@Descripcion varchar(50)
	,@ConfianzaSindical varchar(50)
	,@PorcentajeFondoAhorro decimal(10,3) = 0
	,@IDsConceptosFondoAhorro varchar(max) = null
	,@ToparFondoAhorro bit = 0
	,@Sindical bit = 0
	,@IDUsuario int
)
AS
BEGIN

	SET @Codigo				= UPPER(@Codigo				)
	SET @Descripcion		= UPPER(@Descripcion		)
	SET @ConfianzaSindical  = UPPER(@ConfianzaSindical)

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(@IDTipoPrestacion = 0 OR @IDTipoPrestacion Is null)
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatTiposPrestaciones] where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [RH].[tblCatTiposPrestaciones]([Codigo],[Descripcion],[ConfianzaSindical],PorcentajeFondoAhorro,IDsConceptosFondoAhorro,ToparFondoAhorro,Sindical)
		VALUES(@Codigo,@Descripcion,@ConfianzaSindical,@PorcentajeFondoAhorro,@IDsConceptosFondoAhorro,@ToparFondoAhorro,@Sindical)
		
		set @IDTipoPrestacion = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblCatTiposPrestaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacion = @IDTipoPrestacion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestaciones]','[RH].[spIUCatTiposPrestaciones]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

		IF EXISTS(Select Top 1 1 from RH.[tblCatTiposPrestaciones] where Codigo = @Codigo and IDTipoPrestacion <> @IDTipoPrestacion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON from [RH].[tblCatTiposPrestaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacion = @IDTipoPrestacion

		UPDATE [RH].[tblCatTiposPrestaciones]
		   SET [Codigo] = @Codigo,
			   [Descripcion] = @Descripcion,
			   [ConfianzaSindical] = @ConfianzaSindical,
			   PorcentajeFondoAhorro = @PorcentajeFondoAhorro,
			   IDsConceptosFondoAhorro= @IDsConceptosFondoAhorro,
			   ToparFondoAhorro = @ToparFondoAhorro,
			   Sindical = @Sindical
		 WHERE [IDTipoPrestacion] = @IDTipoPrestacion


		 		select @NewJSON = a.JSON from [RH].[tblCatTiposPrestaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacion = @IDTipoPrestacion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestaciones]','[RH].[spIUCatTiposPrestaciones]','UPDATE',@NewJSON,@OldJSON
	END

  EXEC [Seguridad].[spIUFiltrosUsuarios] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'Prestaciones'  
	 ,@ID = @IDTipoPrestacion   
	 ,@Descripcion = @Descripcion
	 ,@IDUsuarioLogin = @IDUsuario 

 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
END
GO
