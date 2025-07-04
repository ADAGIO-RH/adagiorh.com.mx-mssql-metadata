USE [p_adagioRHIndustrialMefi]
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
	,@Traduccion nvarchar(max)
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

		INSERT INTO [RH].[tblCatTiposPrestaciones](
            [Codigo],
            [Descripcion],
            [ConfianzaSindical],
            PorcentajeFondoAhorro,
            IDsConceptosFondoAhorro,
            ToparFondoAhorro,
            Sindical,
			Traduccion)
		VALUES(
            @Codigo,
            @Descripcion,
            @ConfianzaSindical,
            @PorcentajeFondoAhorro,
            @IDsConceptosFondoAhorro,
            @ToparFondoAhorro,
            @Sindical,
			 case when ISJSON(@Traduccion) > 0 then @Traduccion else null end)
		
		set @IDTipoPrestacion = @@IDENTITY

			select @NewJSON = (SELECT [Codigo],
            [ConfianzaSindical],
            PorcentajeFondoAhorro,
            IDsConceptosFondoAhorro,
            ToparFondoAhorro,
            Sindical,
		    JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
              FROM [RH].[tblCatTiposPrestaciones] 
                WHERE IDTipoPrestacion = @IDTipoPrestacion FOR JSON PATH)

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestaciones]','[RH].[spIUCatTiposPrestaciones]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

		IF EXISTS(Select Top 1 1 from RH.[tblCatTiposPrestaciones] where Codigo = @Codigo and IDTipoPrestacion <> @IDTipoPrestacion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = (SELECT [Codigo],            
            [ConfianzaSindical],
            PorcentajeFondoAhorro,
            IDsConceptosFondoAhorro,
            ToparFondoAhorro,
            Sindical,
		    JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
              FROM [RH].[tblCatTiposPrestaciones] 
                WHERE IDTipoPrestacion = @IDTipoPrestacion FOR JSON PATH)

		UPDATE [RH].[tblCatTiposPrestaciones]
		   SET [Codigo] = @Codigo,
			   [Descripcion] = @Descripcion,
			   [ConfianzaSindical] = @ConfianzaSindical,
			   PorcentajeFondoAhorro = @PorcentajeFondoAhorro,
			   IDsConceptosFondoAhorro= @IDsConceptosFondoAhorro,
			   ToparFondoAhorro = @ToparFondoAhorro,
			   Sindical = @Sindical,
			   Traduccion= case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		 WHERE [IDTipoPrestacion] = @IDTipoPrestacion


		 		select @NewJSON = (SELECT [Codigo],
            [ConfianzaSindical],
            PorcentajeFondoAhorro,
            IDsConceptosFondoAhorro,
            ToparFondoAhorro,
            Sindical,
		    JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
              FROM [RH].[tblCatTiposPrestaciones] 
                WHERE IDTipoPrestacion = @IDTipoPrestacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

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
