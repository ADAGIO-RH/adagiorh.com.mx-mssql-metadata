USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatDivisiones]
(
	@IDDivision int = 0,
	@Codigo varchar(25) = null,
	@Descripcion varchar(50) = null,
	@CuentaContable varchar(25) = null,
	@IDEmpleado int = 0,
	@JefeDivision varchar(100) = null,
    @Traduccion varchar(max) =null,
	@IDUsuario int
)
AS
BEGIN

    
	SET @Codigo				= UPPER(@Codigo			)
	SET @Descripcion 		= UPPER(@Descripcion 	)
	SET @CuentaContable 	= UPPER(@CuentaContable )
	SET @JefeDivision 	= UPPER(@JefeDivision)

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
    

	IF(@IDDivision = 0 or @IDDivision is null)
	BEGIN
	     IF EXISTS(Select Top 1 1 from RH.tblcatDivisiones where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO RH.tblcatDivisiones
			(
			[Codigo]
			,[Descripcion]
			,[CuentaContable]
			,[IDEmpleado]
			,[JefeDivision]
            ,[Traduccion])
		VALUES(
			@Codigo
			,@Descripcion
			,@CuentaContable
			,CASE WHEN @IDEmpleado = 0 THEN null ELSE @IDEmpleado END
			,@JefeDivision
            ,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
			)
			
			set @IDDivision = @@IDENTITY

			Select 
				IDDivision
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,JefeDivision
				,ROW_NUMBER()over(ORDER BY IDDivision)as ROWNUMBER
                ,Traduccion
			FROM RH.tblCatDivisiones
			Where IDDivision = @IDDivision

		select @NewJSON =(SELECT IDDivision
                                ,Codigo
                                ,CuentaContable
                                ,JefeDivision
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatDivisiones]
                            WHERE IDDivision = @IDDivision FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDivisiones]','[RH].[spIUCatDivisiones]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		  IF EXISTS(Select Top 1 1 from RH.tblcatDivisiones where Codigo = @Codigo and IDDivision <> @IDDivision)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
		select @OldJSON = (SELECT IDDivision
                                ,Codigo
                                ,CuentaContable
                                ,JefeDivision
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatDivisiones]
                            WHERE IDDivision = @IDDivision FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		UPDATE RH.tblCatDivisiones
		set [Codigo] = @Codigo
			,[Descripcion] = @Descripcion
			,[CuentaContable] = @CuentaContable
			,[IDEmpleado] = case when @IDEmpleado = 0 then null else @IDEmpleado end
			,[JefeDivision] = @JefeDivision
            ,[Traduccion]=case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
            where IDDivision = @IDDivision
			
			Select 
				IDDivision
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,JefeDivision
				,ROW_NUMBER()over(ORDER BY IDDivision)as ROWNUMBER
                ,Traduccion
			FROM RH.tblCatDivisiones
			Where IDDivision = @IDDivision

		select @NewJSON =(SELECT IDDivision
                                ,Codigo
                                ,CuentaContable
                                ,JefeDivision
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatDivisiones]
                            WHERE IDDivision = @IDDivision FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDivisiones]','[RH].[spIUCatDivisiones]','UPDATE',@NewJSON,@OldJSON
	END

	 EXEC [Seguridad].[spIUFiltrosUsuarios] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'Divisiones'  
	 ,@ID = @IDDivision   
	 ,@Descripcion = @Descripcion
	 ,@IDUsuarioLogin = @IDUsuario 

 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
END
GO
