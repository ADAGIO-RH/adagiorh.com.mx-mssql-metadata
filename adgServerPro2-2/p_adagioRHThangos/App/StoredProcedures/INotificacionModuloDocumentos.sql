USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[INotificacionModuloDocumentos](
  @IDAprobadorDocumento int = 0
 ,@IDDocumento int    
 ,@TipoCambio Varchar(50)
) as  
	declare   
		--@IDUsuario int = 1  
		--,@key varchar(1000) = 'ZMqvYHEdJNDs3GkCkIkDoBz7ONvav2lnvUfArDZy670'  
		@IDNotificacion int = 0  
		,@IDNotificacionPublicador int = 0  
		,@IDTipoNotificacion varchar(100) = 'AprobacionDocumentos'  
		,@ClaveEmpleado  varchar(50)  
		,@NombrePublicador  varchar(255)    
		,@ApellidoPublicador  varchar(255)    
		,@EmailPublicador   varchar(255)  
		,@NombreAutorizar  varchar(255)    
		,@ApellidoAutorizar  varchar(255)    
		,@EmailAutorizar   varchar(255)  
		,@Fecha date  
		,@Folio Varchar(50)
		,@NombreDocumento Varchar(255)
		,@DescripcionDocumento Varchar(255)
		,@TipoDocumento Varchar(255)
		,@valor varchar(max)
		,@valorPublicador varchar(max)
		,@URL Varchar(max)
        ,@IDUsuarioPublicador int
        ,@IDUsuarioAutorizar int 
        ,@TIPO_REFERENCIA_DOCS varchar(255)
	;

    set @TIPO_REFERENCIA_DOCS= '[Docs].[tblCarpetasDocumentos]';

	DECLARE @CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0

	select @SecuenciaMax = isnull(MAX(isnull(secuencia,0)),0) from Docs.tblAprobadoresDocumentos with(nolock) where IDDocumento = @IDDocumento

	select @URL = Valor+'Login/Index?idaplicacion=documentos' from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'Url'

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParamsAutorizador(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);
	create table #tempParamsPublicador(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

	
	IF(@TipoCambio = 'CREATE-AUTORIZA')
	BEGIN

		SELECT TOP 1
			@NombrePublicador = UP.Nombre
			,@ApellidoPublicador = UP.Apellido
			,@EmailPublicador = UP.Email
			,@NombreAutorizar  = U.Nombre
			,@ApellidoAutorizar  = U.Apellido
			,@EmailAutorizar   = U.Email
			,@Fecha = CD.FechaCreacion
			,@Folio = CD.IDItem
			,@NombreDocumento = CD.Nombre
			,@DescripcionDocumento = CD.Descripcion
			,@TipoDocumento = TD.Descripcion
            ,@IDUsuarioAutorizar=U.IDUsuario
            ,@IDUsuarioPublicador =UP.IDUsuario
		from Docs.tblCarpetasDocumentos CD with (nolock)
			inner join Docs.tblAprobadoresDocumentos AD with (nolock)
				on CD.IDItem = AD.IDDocumento
			inner join Seguridad.tblUsuarios U with (nolock)
				on U.IDUsuario = AD.IDUsuario
			inner join Seguridad.tblUsuarios UP	with (nolock)
				on UP.IDUsuario = CD.IDPublicador
			left join Docs.tblCatTiposDocumento TD with (nolock)
				on CD.IDTipoDocumento = TD.IDTipoDocumento
		WHERE CD.IDItem = @IDDocumento
			and AD.Aprobacion = 0
			and AD.Secuencia = @SecuenciaMax
		ORDER BY AD.IDAprobadorDocumento ASC

		IF(ISNULL(@Folio,'') = '')
		BEGIN
			RETURN;
		END

		
		--select @Folio,@NombreDocumento,@DescripcionDocumento,@TipoDocumento,@Fecha
		insert #tempParamsAutorizador(Variable, Valor)
		VALUES
			('Mensaje', 'Se ha generado un documento que requiere su autorización.')
			,('Folio', isnull(@Folio,''))
			,('Nombre', isnull(@NombreDocumento,''))
			,('Descripcion', isnull(@DescripcionDocumento,'SIN DESCRIPCIÓN'))
			,('Tipo', isnull(@TipoDocumento,''))
			,('Fecha', FORMAT(isnull(@Fecha,''),'dd/MM/yyyy HH:mm'))
			,('Link', isnull(@URL,''))
			,('NombreColaborador',coalesce(@NombreAutorizar,''))
		 

		
		--select * from #tempParams
	END

	IF(@TipoCambio = 'DECLINE-AUTORIZA')
	BEGIN

		SELECT TOP 1
			@NombrePublicador = UP.Nombre
			,@ApellidoPublicador = UP.Apellido
			,@EmailPublicador = UP.Email
			,@NombreAutorizar  = U.Nombre
			,@ApellidoAutorizar  = U.Apellido
			,@EmailAutorizar   = U.Email
			,@Fecha = CD.FechaCreacion
			,@Folio = CD.IDItem
			,@NombreDocumento = CD.Nombre
			,@DescripcionDocumento = CD.Descripcion
			,@TipoDocumento = TD.Descripcion
            ,@IDUsuarioAutorizar =U.IDUsuario
            ,@IDUsuarioPublicador =UP.IDUsuario
		from Docs.tblCarpetasDocumentos CD with (nolock)
			inner join Docs.tblAprobadoresDocumentos AD with (nolock)
				on CD.IDItem = AD.IDDocumento
			inner join Seguridad.tblUsuarios U with (nolock)
				on U.IDUsuario = AD.IDUsuario
			inner join Seguridad.tblUsuarios UP	with (nolock)
				on UP.IDUsuario = CD.IDPublicador
			left join Docs.tblCatTiposDocumento TD with (nolock)
				on CD.IDTipoDocumento = TD.IDTipoDocumento
		WHERE CD.IDItem = @IDDocumento
			and AD.IDAprobadorDocumento = @IDAprobadorDocumento

		IF(ISNULL(@Folio,'') = '')
		BEGIN
			RETURN;
		END
		--select @Folio,@NombreDocumento,@DescripcionDocumento,@TipoDocumento,@Fecha
		insert #tempParamsAutorizador(Variable, Valor)
		VALUES
			('Mensaje', 'Se ha declinado tu documento.')
			,('Folio', isnull(@Folio,''))
			,('Nombre', isnull(@NombreDocumento,''))
			,('Descripcion', isnull(@DescripcionDocumento,'SIN DESCRIPCIÓN'))
			,('Tipo', isnull(@TipoDocumento,''))
			,('Fecha', FORMAT(isnull(@Fecha,''),'dd/MM/yyyy HH:mm'))
			,('Link', isnull(@URL,''))
			,('NombreColaborador',coalesce(@NombreAutorizar,''))

		insert #tempParamsPublicador(Variable, Valor)
		VALUES
			('Mensaje', 'Se ha declinado tu documento.')
			,('Folio', isnull(@Folio,''))
			,('Nombre', isnull(@NombreDocumento,''))
			,('Descripcion', isnull(@DescripcionDocumento,'SIN DESCRIPCIÓN'))
			,('Tipo', isnull(@TipoDocumento,''))
			,('Fecha', FORMAT(isnull(@Fecha,''),'dd/MM/yyyy HH:mm'))
			,('Link', isnull(@URL,''))
			,('NombreColaborador',coalesce(@NombrePublicador,''))
		 

	END

	IF(@TipoCambio = 'COMPLETE-SECUENCIA')
	BEGIN
		
		SELECT TOP 1
			 @NombrePublicador = UP.Nombre
			,@ApellidoPublicador = UP.Apellido
			,@EmailPublicador = UP.Email
			,@EmailAutorizar = UP.Email
			,@Fecha = CD.FechaCreacion
			,@Folio = CD.IDItem
			,@NombreDocumento = CD.Nombre
			,@DescripcionDocumento = CD.Descripcion
			,@TipoDocumento = TD.Descripcion
            ,@IDUsuarioAutorizar=UP.IDUsuario
            ,@IDUsuarioPublicador=UP.Email
		from Docs.tblCarpetasDocumentos CD with (nolock)
			inner join Seguridad.tblUsuarios UP	with (nolock)
				on UP.IDUsuario = CD.IDPublicador
			left join Docs.tblCatTiposDocumento TD with (nolock)
				on CD.IDTipoDocumento = TD.IDTipoDocumento
		WHERE CD.IDItem = @IDDocumento

		IF(ISNULL(@Folio,'') = '')
		BEGIN
			RETURN;
		END

		--select @Folio,@NombreDocumento,@DescripcionDocumento,@TipoDocumento,@Fecha
		insert #tempParamsPublicador(Variable, Valor)
		VALUES
			('Mensaje', 'Se ha completado la secuencia de aprobación de tu documento.')
			,('Folio', isnull(@Folio,''))
			,('Nombre', isnull(@NombreDocumento,''))
			,('Descripcion', isnull(@DescripcionDocumento,'SIN DESCRIPCIÓN'))
			,('Tipo', isnull(@TipoDocumento,''))
			,('Fecha', FORMAT(isnull(@Fecha,''),'dd/MM/yyyy HH:mm'))
			,('Link', isnull(@URL,''))
			,('NombreColaborador',coalesce(@NombrePublicador,''))
		 
	END

	 DECLARE 
		@cols AS NVARCHAR(MAX),
		@query  AS NVARCHAR(MAX)
	;

	IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivotAutorizador') IS NOT NULL DROP TABLE ##tempParamsPivotAutorizador
	IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivotPublicador') IS NOT NULL DROP TABLE ##tempParamsPivotPublicador
	
	IF((select count(*) from #tempParamsAutorizador) > 0)
	BEGIN

		SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
				FROM #tempParamsAutorizador c
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')

		set @query = 'SELECT  ' + @cols + ' 
				into ##tempParamsPivotAutorizador
				from 
				(
					select Variable
						, Valor
                   
					from #tempParamsAutorizador
			   ) x
				pivot 
				(
					 max(Valor)
					for Variable in (' + @cols + ')
				) p '

		execute(@query)

		select @valor = a.JSON 
		from ##tempParamsPivotAutorizador b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	END

	IF((select count(*) from #tempParamsPublicador) > 0)
	BEGIN
		SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
				FROM #tempParamsPublicador c
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')

		set @query = 'SELECT  ' + @cols + ' 
				into ##tempParamsPivotPublicador
				from 
				(
					select Variable
						, Valor
                   
					from #tempParamsPublicador
			   ) x
				pivot 
				(
					 max(Valor)
					for Variable in (' + @cols + ')
				) p '

		execute(@query)

		select @valorPublicador = a.JSON 
		from ##tempParamsPivotPublicador b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	END

	
	BEGIN TRY
		declare @tran int 
		set @tran = @@TRANCOUNT
		if(@tran = 0)
		BEGIN
			BEGIN TRAN 
		END
		
			IF((select count(*) from #tempParamsAutorizador) > 0)
			BEGIN
				insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
				SELECT @IDTipoNotificacion,@valor
				set @IDNotificacion = @@IDENTITY
			END

			
			IF((select count(*) from #tempParamsPublicador) > 0)
			BEGIN
				insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
				SELECT @IDTipoNotificacion,@valorPublicador
				set @IDNotificacionPublicador = @@IDENTITY
			END
			  
			IF(@TipoCambio <> 'COMPLETE-SECUENCIA')
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
                    ,TipoReferencia
                    ,IDReferencia
                    ,IDUsuario) 
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,case when templateNot.IDMedioNotificacion = 'Email' then @EmailAutorizar else null end  
					,NULL 
                    ,@TIPO_REFERENCIA_DOCS
                    ,@IDDocumento
                    ,@IDUsuarioAutorizar
                    

				from 	[App].[tblTiposNotificaciones] tn  
					INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
					and tn.IDTipoNotificacion = @IDTipoNotificacion
			END

			IF(@TipoCambio = 'DECLINE-AUTORIZA' OR @TipoCambio = 'COMPLETE-SECUENCIA')	
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
                    ,TipoReferencia
                    ,IDReferencia
                    ,IDUsuario) 
				select 
					@IDNotificacionPublicador  
					,templateNot.IDMedioNotificacion  
					,case when templateNot.IDMedioNotificacion = 'Email' then @EmailPublicador else null end  
					,NULL 
                    ,@TIPO_REFERENCIA_DOCS
                    ,@IDDocumento
                    ,@IDUsuarioPublicador
				from 	[App].[tblTiposNotificaciones] tn  
					INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
					and tn.IDTipoNotificacion = @IDTipoNotificacion

			END
		

	    if(@tran = 0)
		BEGIN
			COMMIT TRAN 
		END

	
	END TRY
	BEGIN CATCH
		if (@tran=0)
		BEGIN
			ROLLBACK TRAN 
		END
	END CATCH
GO
