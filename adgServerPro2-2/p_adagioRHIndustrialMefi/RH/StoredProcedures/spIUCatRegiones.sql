USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatRegiones]
(
	@IDRegion int = 0,
	@Codigo varchar(25) = null,
	@Descripcion varchar(50) = null,
	@CuentaContable varchar(25) = null,
	@IDEmpleado int = 0,
	@JefeRegion varchar(100) = null,
	@IDUsuario int,
    @Traduccion varchar(max)=null
)
AS
BEGIN

	SET @Codigo			= UPPER(@Codigo			)
	SET @Descripcion 	= UPPER(@Descripcion 	)
	SET @CuentaContable = UPPER(@CuentaContable )
	SET @JefeRegion 	= UPPER(@JefeRegion 	)


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDRegion = 0 or @IDRegion is null)
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.tblcatRegiones where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO RH.tblcatRegiones
			(
			[Codigo]
			,[Descripcion]
			,[CuentaContable]
			,[IDEmpleado]
			,[JefeRegion]
            ,[Traduccion])
		VALUES(
			@Codigo
			,@Descripcion
			,@CuentaContable
			,CASE WHEN @IDEmpleado = 0 THEN null ELSE @IDEmpleado END
			,@JefeRegion
            ,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
			)
			
			set @IDRegion = @@IDENTITY

		select @NewJSON =(SELECT IDRegion
                                ,Codigo
                                ,CuentaContable
                                ,JefeRegion
                                ,IDEmpleado                              
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatRegiones]
                            WHERE IDRegion = @IDRegion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblcatRegiones]','[RH].[spIUCatRegiones]','INSERT',@NewJSON,''


			Select 
				IDRegion
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,JefeRegion
                ,Traduccion
				,ROW_NUMBER()over(ORDER BY IDRegion)as ROWNUMBER
			FROM RH.tblCatRegiones
			Where IDREgion = @IDRegion
	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.tblCatRegiones where Codigo = @Codigo and IDRegion <> @IDRegion) 
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
				select @OldJSON = (SELECT IDRegion
                                ,Codigo
                                ,CuentaContable
                                ,JefeRegion
                                ,IDEmpleado                              
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatRegiones]
                            WHERE IDRegion = @IDRegion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		UPDATE RH.tblCatRegiones
		set [Codigo] = @Codigo
			,[Descripcion] = @Descripcion
			,[CuentaContable] = @CuentaContable
			,[IDEmpleado] = case when @IDEmpleado = 0 then null else @IDEmpleado end
			,[JefeRegion] = @JefeRegion
            ,[Traduccion]= case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		Where IDRegion = @IDRegion
			
			
		select @NewJSON = (SELECT IDRegion
                                ,Codigo
                                ,CuentaContable
                                ,JefeRegion
                                ,IDEmpleado                              
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatRegiones]
                            WHERE IDRegion = @IDRegion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblcatRegiones]','[RH].[spIUCatRegiones]','UPDATE',@NewJSON,@OldJSON

			Select 
				IDRegion
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,JefeRegion
                ,Traduccion
				,ROW_NUMBER()over(ORDER BY IDRegion)as ROWNUMBER
			FROM RH.tblCatRegiones
			Where IDRegion = @IDRegion
	END
END
GO
