USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[spINotificacionProyectoClonado] (
	@IDProyecto int
) as

	DECLARE 
		@NombreProyecto		varchar(max)
		,@TotalPruebas		int = 0
		,@TotalRealizadas	int = 0 

		,@NombreAdministradorProyecto	varchar(max)		
		,@EmailAdministradorProyecto	varchar(max)	

		,@NombreContactoProyecto varchar(max)		
		,@EmailContactoProyecto	varchar(max)	

		,@xmlParametros varchar(max)		
		,@IDNotificacion int
		,@IDTipoNotificacion varchar(100) = 'NotificarProyectoClonado'  
        ,@TIPO_REFERENCIA_NOTIFICARPROYECTOCLONADO varchar(255);
	;

    set @TIPO_REFERENCIA_NOTIFICARPROYECTOCLONADO='[Evaluacion360].[tblEncargadosProyectos]'

	declare 
		@htmlAdministrador varchar(max),
		@subjectAdministrador varchar(300),
		@htmlContacto varchar(max),
		@subjectContacto varchar(300)
	;

	select @NombreProyecto = Nombre
	from Evaluacion360.tblCatProyectos
	where IDProyecto = @IDProyecto

	SELECT 
		 @NombreAdministradorProyecto = CASE WHEN tep.IDCatalogoGeneral = 1 THEN coalesce(tep.Nombre,'') ELSE @NombreAdministradorProyecto end
		 ,@EmailAdministradorProyecto = CASE WHEN tep.IDCatalogoGeneral = 1 THEN coalesce(tep.Email,'') ELSE @EmailAdministradorProyecto end
	FROM [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
	WHERE tep.IDProyecto = @IDProyecto 

	SELECT 
		 @NombreContactoProyecto = CASE WHEN tep.IDCatalogoGeneral = 3 THEN coalesce(tep.Nombre,'') ELSE @NombreContactoProyecto end
		 ,@EmailContactoProyecto = CASE WHEN tep.IDCatalogoGeneral = 3 THEN coalesce(tep.Email,'') ELSE @EmailContactoProyecto end
	FROM [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
	WHERE tep.IDProyecto = @IDProyecto 

	if (LEN(@NombreAdministradorProyecto) > 0)
	begin
		select 
			@subjectAdministrador = '¡Acción requerida! Completa y Autoriza la prueba '+coalesce(@NombreProyecto, ''),
			@htmlAdministrador = N'
			<p>Hola '+@NombreAdministradorProyecto+', <p> <br />
			Se generó la prueba <b>'+coalesce(@NombreProyecto, '')+'</b>, completa los últimos pasos y autorízala.
			<br />			
			<br />	
			Esta prueba fue generada automaticamente debido a la canlendarización de otra prueba.
			'	

		if ([Utilerias].[fsValidarEmail](@EmailAdministradorProyecto) = 1)
		begin
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
			SELECT @IDTipoNotificacion,'{ "subject":"'+@subjectAdministrador+'", "body": "'+@htmlAdministrador+'"}'

			set @IDNotificacion = @@IDENTITY  
			insert [App].[tblEnviarNotificacionA](  
				IDNotifiacion  
				,IDMedioNotificacion  
				,Destinatario
				,Adjuntos
                ,TipoReferencia
                ,IDReferencia
                ,IDUsuario

                ) 
			select 
				@IDNotificacion  
				,templateNot.IDMedioNotificacion  
				,case when templateNot.IDMedioNotificacion = 'Email' then @EmailAdministradorProyecto else null end  
				,NULL 
                ,@TIPO_REFERENCIA_NOTIFICARPROYECTOCLONADO
                ,@IDProyecto
                , 1 -- EL ADMIN YA QUE NO HAY IDUSUARIO RELACIONADO
			from [App].[tblTiposNotificaciones] tn  
				INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
			where tn.IDTipoNotificacion = @IDTipoNotificacion
		end
	end

	if (LEN(@NombreContactoProyecto) > 0)
	begin
		select 
			@subjectContacto = 'La prueba '+coalesce(@NombreProyecto, '')+' ha sido iniciada y requiere ser completada por el administrador',
			@htmlContacto = N'
			<p>Hola '+@NombreContactoProyecto+', <p> <br />
			Se generó la prueba <b>'+coalesce(@NombreProyecto, '')+'</b>, es necesario completar algunos pasas y autorizar la prueba. 
				<br />			
				<br />	
			Esta prueba fue generada automaticamente debido a la canlendarización de otra prueba.
			'	

		if ([Utilerias].[fsValidarEmail](@EmailContactoProyecto) = 1)
		begin
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
			SELECT @IDTipoNotificacion,'{ "subject":"'+@subjectContacto+'", "body": "'+@htmlContacto+'"}'

			set @IDNotificacion = @@IDENTITY  
			insert [App].[tblEnviarNotificacionA](  
				IDNotifiacion  
				,IDMedioNotificacion  
				,Destinatario
				,Adjuntos
                ,TipoReferencia
                ,IDReferencia
                ,IDUsuario
                ) 
			select 
				@IDNotificacion  
				,templateNot.IDMedioNotificacion  
				,case when templateNot.IDMedioNotificacion = 'Email' then @EmailContactoProyecto else null end  
				,NULL 
                ,@TIPO_REFERENCIA_NOTIFICARPROYECTOCLONADO
                ,@IDProyecto
                , 1 -- EL ADMIN YA QUE NO HAY IDUSUARIO RELACIONADO
			from [App].[tblTiposNotificaciones] tn  
				INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
			where tn.IDTipoNotificacion = @IDTipoNotificacion
		end
	end
GO
