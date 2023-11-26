USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatPuestos](
	@IDPuesto int = 0
	,@Codigo varchar(20) = null
	,@Descripcion varchar(50) = null
	,@DescripcionPuesto nvarchar(max) = null
	,@SueldoBase money = null
	,@TopeSalarial money = null
	,@IDOcupacion int = null
    ,@IDUsuario int 
	,@Traduccion Varchar(max) = null
)
AS
BEGIN
	SET @Codigo				= UPPER(@Codigo				)
	SET @Descripcion 		= UPPER(@Descripcion 		)
	--SET @DescripcionPuesto 	= UPPER(@DescripcionPuesto 	)

	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	IF (@IDPuesto = 0 or @IDPuesto is null)
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatPuestos] where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
		 SET @Descripcion=JSON_VALUE(@Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))

		INSERT INTO [RH].[tblCatPuestos](Codigo,Descripcion,DescripcionPuesto,SueldoBase,TopeSalarial,IDOcupacion, Traduccion)
		VALUES(
			@Codigo, 
			@Descripcion, 
			@DescripcionPuesto, 
			@SueldoBase, 
			@TopeSalarial, 
			CASE WHEN @IDOcupacion = 0 then null else @IDOcupacion end,
			case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		)
		Set @IDPuesto = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatPuestos] b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPuesto = @IDPuesto

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatPuestos]','[RH].[spIUCatPuestos]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatPuestos] where Codigo = @Codigo and IDPuesto <> @IDPuesto) 
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON from [RH].[tblCatPuestos] b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPuesto = @IDPuesto

		UPDATE [RH].[tblCatPuestos]
		   SET  [Codigo]				= @Codigo
				,[Descripcion]			= @Descripcion
				,[DescripcionPuesto]	= @DescripcionPuesto
				,[SueldoBase]		= @SueldoBase
				,[TopeSalarial]		= @TopeSalarial
				,[IDOcupacion]		= CASE WHEN @IDOcupacion = 0 then null else @IDOcupacion end
				,[Traduccion]		= case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
				
		 WHERE [IDPuesto] = @IDPuesto

		select @NewJSON = a.JSON from [RH].[tblCatPuestos] b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPuesto = @IDPuesto

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatPuestos]','[RH].[spIUCatPuestos]','UPDATE',@NewJSON,@OldJSON
	END
	
	exec [RH].[spBuscarCatPuestos] @IDPuesto

	EXEC [Seguridad].[spIUFiltrosUsuarios] 
		@IDFiltrosUsuarios  = 0  
		,@IDUsuario  = @IDUsuario   
		,@Filtro = 'Puestos'  
		,@ID = @IDPuesto   
		,@Descripcion = @Descripcion
		,@IDUsuarioLogin = @IDUsuario 
		,@IDCatFiltroUsuario = 0

	exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
END
GO
