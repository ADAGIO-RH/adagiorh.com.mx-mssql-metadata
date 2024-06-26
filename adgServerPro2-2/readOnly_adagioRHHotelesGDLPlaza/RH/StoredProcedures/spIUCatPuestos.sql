USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '0302003'

--select * from Seguridad.tblUsuarios
--select * from app.tblPreferencias where App.tblPreferencias.IDPreferencia = 1
--select * from app.tblDetallePreferencias where IDPreferencia = 1
    
CREATE PROCEDURE [RH].[spIUCatPuestos]
(
	@IDPuesto int = 0
	,@Codigo varchar(20) = null
	,@Descripcion varchar(50) = null
	,@DescripcionPuesto nvarchar(max) = null
	,@SueldoBase money = null
	,@TopeSalarial money = null
	,@NivelSalarial  varchar(50) = null
	,@IDOcupacion int = null
     ,@IDUsuario int 
)
AS
BEGIN
	SET @Codigo				= UPPER(@Codigo				)
	SET @Descripcion 		= UPPER(@Descripcion 		)
	SET @DescripcionPuesto 	= UPPER(@DescripcionPuesto 	)
	SET @NivelSalarial 		= UPPER(@NivelSalarial 		)

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


	IF (@IDPuesto = 0 or @IDPuesto is null)
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatPuestos] where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [RH].[tblCatPuestos]
				   (
					Codigo
					,Descripcion
					,DescripcionPuesto
					,SueldoBase
					,TopeSalarial
					,NivelSalarial
					,IDOcupacion
				   )
			 VALUES
				   (
				   @Codigo
				   ,@Descripcion
				   ,@DescripcionPuesto
				   ,@SueldoBase
				   ,@TopeSalarial
				   ,@NivelSalarial
				   ,CASE WHEN @IDOcupacion = 0 then null else @IDOcupacion end
				   )
		Set @IDPuesto = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblCatPuestos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPuesto = @IDPuesto

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatPuestos]','[RH].[spIUCatPuestos]','INSERT',@NewJSON,''

		exec [RH].[spBuscarCatPuestos] @IDPuesto

	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatPuestos] where Codigo = @Codigo and IDPuesto <> @IDPuesto) 
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

			select @OldJSON = a.JSON from [RH].[tblCatPuestos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPuesto = @IDPuesto

		UPDATE [RH].[tblCatPuestos]
		   SET  [Codigo] = @Codigo
				,[Descripcion] = @Descripcion
				,[DescripcionPuesto] = @DescripcionPuesto
				,[SueldoBase] = @SueldoBase
				,[TopeSalarial] = @TopeSalarial
				,[NivelSalarial] = @NivelSalarial
				,[IDOcupacion] = CASE WHEN @IDOcupacion = 0 then null else @IDOcupacion end
		 WHERE [IDPuesto] = @IDPuesto

		 select @NewJSON = a.JSON from [RH].[tblCatPuestos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPuesto = @IDPuesto

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatPuestos]','[RH].[spIUCatPuestos]','UPDATE',@NewJSON,@OldJSON

		  exec [RH].[spBuscarCatPuestos] @IDPuesto

	END

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
