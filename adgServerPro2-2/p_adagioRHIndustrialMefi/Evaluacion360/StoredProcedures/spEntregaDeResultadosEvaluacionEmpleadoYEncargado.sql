USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Genera notificaciones para el Colaborador y para el Encagado de la prueba adjuntos reporte de la prueba.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-05-05
** Paremetros		:              

** DataTypes Relacionados: 
	1- App.dtAdgFiles
		[name]: En este caso hace referencia al IDEmpleadoProyecto
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2021-07-08			Aneudy Abreu	Se modificó el Subject de los correos
2024-01-09          Andrea Zainos   Se agrega validacion para que si el email no es valido, no trate de enviar la notificacion
***************************************************************************************************/
CREATE proc [Evaluacion360].[spEntregaDeResultadosEvaluacionEmpleadoYEncargado] (
	@IDProyecto int,
	@filesIndividuales App.dtAdgFiles readonly
) as
	declare
		--@filesIndividuales App.dtAdgFiles,
		--@filesCompromidos App.dtAdgFiles,
		--@IDProyecto int = 5,
		@Link varchar(max),
		@IDAdgFile int,
		@IDAdgFileZIP int,
		@IDEvaluacionEmpleado int,
		@IDNotificacion int,
		@IDTipoNotificacionColaborador varchar(200) = 'EntregaDeResultadosEvaluacionEmpleado',
		@IDTipoNotificacionEncargado varchar(200) = 'EntregaDeResultadosEvaluacionEmpleadoEncargado',
		@Email varchar(max),

		@Proyecto varchar(max),
		@AdministradorProyecto	varchar(max),		
		@EmailAdministradorProyecto	varchar(max),	
		@AuditorProyecto		varchar(max),		
		@ContactoProyecto		varchar(max),
		@NombreContactoProyecto	varchar(255),		
		@EmailContactoProyecto varchar(255),

		@NombreEvaluador	varchar(255),		
		@EmailEvaluador varchar(255),
		@subjectZIP varchar(max),
		@bodyZIP varchar(max),

		@adjunto varchar(max),
		@IDEmpleado int,
        @EmailColaborador VARCHAR(255)
	;
	
	select top 1 @Link = valor 
	from App.tblConfiguracionesGenerales with (nolock)
	where IDConfiguracion = 'Url'

	select @Proyecto = Nombre
	from Evaluacion360.tblCatProyectos with (nolock)
	WHERE IDProyecto = @IDProyecto 

	SELECT 
		 @AdministradorProyecto			= CASE WHEN tep.IDCatalogoGeneral = 1 THEN coalesce(tep.Nombre,'') ELSE @AdministradorProyecto end
		,@EmailAdministradorProyecto	= CASE WHEN tep.IDCatalogoGeneral = 1 THEN coalesce(tep.Email,'') ELSE @EmailAdministradorProyecto end
	FROM [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
	WHERE tep.IDProyecto = @IDProyecto 
	
	BEGIN -- Email individuales colaboradores/evaluadores
		DECLARE @archive as TABLE
		(
			ActionType		varchar(10) null,
			IDAdgFile		int,
			[name]			varchar(max),
			extension		varchar(max),
			pathFile		varchar(max),
			relativePath	varchar(max),
			downloadURL		varchar(max),
			requiereAutenticacion bit,
			[IDEnviarNotificacionColaborador] int null,
			[IDEnviarNotificacionEvaluador] int null
		);

		-- truncate table App.tblAdgFiles
		MERGE App.tblAdgFiles AS TARGET
		USING @filesIndividuales AS SOURCE
		ON TARGET.IDAdgFile = 0
		WHEN NOT MATCHED THEN
		   INSERT
		   (
			  [name],
			  extension,
			  pathFile,
			  relativePath,
			  downloadURL,
			  requiereAutenticacion
		   )
		   VALUES
		   (
			  SOURCE.[name],
			  SOURCE.extension,
			  SOURCE.pathFile,
			  SOURCE.relativePath,
			  SOURCE.downloadURL,
			  1
		   )
		OUTPUT
		  $action AS ActionType,
		 inserted.IDAdgFile,
		 inserted.[name],
		 inserted.extension,
		 inserted.pathFile,
		 inserted.relativePath,
		 inserted.downloadURL,
		 inserted.requiereAutenticacion,
		 null, null
		INTO @archive;

		--SELECT  * FROM  @archive --WHERE ActionType IN ( 'DELETE', 'UPDATE' );

		BEGIN -- EmailColaborador
			if object_id('tempdb..#tempEmailsColaboradores') is not null drop table #tempEmailsColaboradores;

			select 
				f.*,
				p.Nombre as Proyecto,
				e.IDEmpleado,
				e.ClaveEmpleado, 
				e.Nombre as Colaborador,
				Email = case when c.Email is not null then c.Email else u.Email end
			INTO #tempEmailsColaboradores
			from [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock)
				join @archive f on cast(f.[name] as int ) = ep.IDEmpleadoProyecto  
				join [Evaluacion360].[tblCatProyectos] p with (nolock) on p.IDProyecto = ep.IDProyecto
				join Evaluacion360.tblEnviarResultadosAColaboradores enviarResultado with (nolock) on enviarResultado.IDEmpleadoProyecto = ep.IDEmpleadoProyecto and isnull(enviarResultado.Valor, 1) = 1
				join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = ep.IDEmpleado
				left join Seguridad.tblUsuarios u with (nolock) on u.IDEmpleado = e.IDEmpleado
				left join (
					select ce.IDEmpleado
						,lower(ce.[Value]) as Email
						,ce.Predeterminado
						,ROW_NUMBER()OVER(partition by ce.IDEmpleado order by ce.Predeterminado desc) as [ROW]
					from RH.tblContactoEmpleado ce with (nolock)
						join [RH].[tblCatTipoContactoEmpleado] ctce with (nolock) on ctce.IDTipoContacto = ce.IDTipoContactoEmpleado 
							and ctce.IDMedioNotificacion = 'email'
					where ce.[Value] is not null
				) c on c.IDEmpleado = e.IDEmpleado and c.[ROW] = 1
			WHERE ep.PDFGenerado = 1

				--select * from #tempEmailsColaboradores
			if object_id('tempdb..#tempTemplateEmailsColaboradores') is not null drop table #tempTemplateEmailsColaboradores;              
                select
                    IDAdgFile,
                    IDEnviarNotificacionColaborador,
                    IDEnviarNotificacionEvaluador,
                    pathFile,
                    IDEmpleado,
                    Email,
                    [subject] = N'Hola '+Colaborador+', Te entregamos los resultados de la prueba '+coalesce(@Proyecto, ''),
                    html = N'
                        <p>'+Colaborador+' te hacemos entrega de los resultados de la prueba <b>'+Proyecto+'.</b></p>
                        <br />
                        <p style=''text-align: center;margin-bottom: 30px;''>
                            También puedes descarga el resultado <a style=''font-weight: 600;color: black;cursor: pointer;'' href='''+@Link+'App/download?id='+cast(IDAdgFile as varchar(100))+'''> aquí</a>
                        </p>
                    '
                INTO #tempTemplateEmailsColaboradores
                from #tempEmailsColaboradores

                select @IDAdgFile = min(IDAdgFile) from #tempTemplateEmailsColaboradores
                while exists (select top 1 1 from #tempTemplateEmailsColaboradores where IDAdgFile >= @IDAdgFile)
                begin
                       select 
                        @Email = Email,
                        @IDEmpleado = IDEmpleado
                        ,@adjunto = pathFile
                    from #tempTemplateEmailsColaboradores
                    where IDAdgFile = @IDAdgFile

                        select top 1 @Email = ISNULL(CE.Value,U.Email) 
                        from App.tblTiposNotificaciones TN
                            inner join App.tblTemplateNotificaciones Template on TN.IDTipoNotificacion = Template.IDTipoNotificacion
                            left join [RH].[tblContactosEmpleadosTiposNotificaciones] CETN on TN.IDTipoNotificacion = CETN.IDTipoNotificacion
                                    and CETN.IDEmpleado = @IDEmpleado
                            left join RH.tblContactoEmpleado CE on CE.IDContactoEmpleado = CETN.IDContactoEmpleado
                            left join Seguridad.tblUsuarios u  on U.IDEmpleado = @IDEmpleado
                        WHERE TN.IDTipoNotificacion = @IDTipoNotificacionColaborador and Template.IDMedioNotificacion = 'EMAIL'

          
                if ([Utilerias].[fsValidarEmail](@Email) = 1)
                BEGIN
         
                        insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
                        SELECT @IDTipoNotificacionColaborador,'{ "subject":"'+[subject]+'", "body": "'+[html]+'"}'
                        from #tempTemplateEmailsColaboradores
                        where IDAdgFile = @IDAdgFile
                


                        set @IDNotificacion = @@IDENTITY  
                        insert [App].[tblEnviarNotificacionA](  
                            IDNotifiacion  
                            ,IDMedioNotificacion  
                            ,Destinatario
                            ,Adjuntos) 
                        select 
                            @IDNotificacion  
                            ,templateNot.IDMedioNotificacion  
                            ,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
                            ,@adjunto 
                        from [App].[tblTiposNotificaciones] tn  
                            INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
                        where tn.IDTipoNotificacion = @IDTipoNotificacionColaborador

                        update @archive
                            set IDEnviarNotificacionColaborador = @@IDENTITY
                        WHERE IDAdgFile = @IDAdgFile
                    end
                    select @IDAdgFile = min(IDAdgFile) from #tempTemplateEmailsColaboradores where IDAdgFile > @IDAdgFile
            END
		END

		BEGIN -- EmailEvaluador
			if object_id('tempdb..#tempEmailsEvaluadores') is not null drop table #tempEmailsEvaluadores;

			select 
				eva.IDEvaluacionEmpleado,
				f.*,
				p.Nombre as Proyecto,
				e.IDEmpleado,
				e.ClaveEmpleado, 
				e.Nombre as Evaluador,
				Email = case when c.Email is not null then c.Email else u.Email end
			INTO #tempEmailsEvaluadores
			from [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock)
				join Evaluacion360.tblEnviarResultadosAColaboradores enviarResultado with (nolock) on enviarResultado.IDEmpleadoProyecto = ep.IDEmpleadoProyecto and isnull(enviarResultado.Valor, 1) = 1
				join [Evaluacion360].[tblEvaluacionesEmpleados] eva on eva.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
				join @archive f on cast(f.[name] as int ) = ep.IDEmpleadoProyecto  
				join [Evaluacion360].[tblCatProyectos] p with (nolock) on p.IDProyecto = ep.IDProyecto
				join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = eva.IDEvaluador
				left join Seguridad.tblUsuarios u with (nolock) on u.IDEmpleado = e.IDEmpleado
				left join (
					select ce.IDEmpleado
						,lower(ce.[Value]) as Email
						,ce.Predeterminado
						,ROW_NUMBER()OVER(partition by ce.IDEmpleado order by ce.Predeterminado desc) as [ROW]
					from RH.tblContactoEmpleado ce with (nolock)
						join [RH].[tblCatTipoContactoEmpleado] ctce with (nolock) on ctce.IDTipoContacto = ce.IDTipoContactoEmpleado 
							and ctce.IDMedioNotificacion = 'email'
					where ce.[Value] is not null
				) c on c.IDEmpleado = e.IDEmpleado and c.[ROW] = 1
			WHERE ep.PDFGenerado = 1

			if object_id('tempdb..#tempTemplateEmailsEvaluadores') is not null drop table #tempTemplateEmailsEvaluadores;
     
			select
				IDEvaluacionEmpleado,
				IDAdgFile,
				IDEnviarNotificacionColaborador,
				IDEnviarNotificacionEvaluador,
				pathFile,
				IDEmpleado,
				Email,
				[subject] = N'Hola '+Evaluador+', Te entregamos los resultados de la prueba que realizaste.',
				html = N'
					<p>'+Evaluador+' te hacemos entrega de los resultados de la prueba <b>'+Proyecto+'.</b></p>
					<br />
					<p style=''text-align: center;margin-bottom: 30px;''>
						También puedes descarga el resultado <a style=''font-weight: 600;color: black;cursor: pointer;'' href='''+@Link+'App/download?id='+cast(IDAdgFile as varchar(100))+'''> aquí</a>
					</p>
				'
			INTO #tempTemplateEmailsEvaluadores
			from #tempEmailsEvaluadores

			select @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) from #tempTemplateEmailsEvaluadores
			while exists (select top 1 1 from #tempTemplateEmailsEvaluadores where IDEvaluacionEmpleado >= @IDEvaluacionEmpleado)
			begin            
				select 
					@IDAdgFile = IDAdgFile, 
					@Email = Email,
					@adjunto = pathFile
				from #tempTemplateEmailsEvaluadores
				where IDEvaluacionEmpleado = @IDEvaluacionEmpleado
         

            if ([Utilerias].[fsValidarEmail](@Email) = 1)
            BEGIN
         
                	insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
                	SELECT @IDTipoNotificacionColaborador,'{ "subject":"'+[subject]+'", "body": "'+[html]+'"}'
                	from #tempTemplateEmailsEvaluadores
                	where IDEvaluacionEmpleado = @IDEvaluacionEmpleado



                	set @IDNotificacion = @@IDENTITY  
                	insert [App].[tblEnviarNotificacionA](  
                		IDNotifiacion  
                		,IDMedioNotificacion  
                		,Destinatario
                		,Adjuntos) 
                	select 
                		@IDNotificacion  
                		,templateNot.IDMedioNotificacion  
                		,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
                		,@adjunto 
                	from [App].[tblTiposNotificaciones] tn  
                		INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
                	where tn.IDTipoNotificacion = @IDTipoNotificacionColaborador
            
                	update @archive
                		set IDEnviarNotificacionEvaluador = @@IDENTITY
                	WHERE IDAdgFile = @IDAdgFile

                   
                end
                 select @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) from #tempTemplateEmailsEvaluadores where IDEvaluacionEmpleado > @IDEvaluacionEmpleado
            END
		END

		select * from @archive
	END
GO
