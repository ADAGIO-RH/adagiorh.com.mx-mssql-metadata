USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Genera notificaciones para el Administrador de la prueba adjuntos reporte de la prueba.
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
***************************************************************************************************/
CREATE proc [Evaluacion360].[spEntregaDeResultadosEvaluacionAdministrador] (
	@IDProyecto int,
	@filesCompromidos App.dtAdgFiles readonly
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
		@IDEmpleado int
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
	
	BEGIN -- Email Administrador
		insert App.tblAdgFiles ([name],extension,pathFile,relativePath,downloadURL,requiereAutenticacion)
		select [name],extension,pathFile,relativePath,downloadURL,1
		from @filesCompromidos

		set @IDAdgFileZIP = @@IDENTITY

		select top 1
			@subjectZIP = N'Hola '+@AdministradorProyecto+', Te entregamos los resultados de la prueba '+coalesce(@Proyecto, ''),
			@bodyZIP = N'
				<p>'+@AdministradorProyecto+' te hacemos entrega de los resultados de la prueba <b>'+@Proyecto+'.</b></p>
				<br />
				<p style=''text-align: center;margin-bottom: 30px;''>
					Descarga los resultados <a style=''font-weight: 600;color: black;cursor: pointer;'' href='''+@Link+'App/download?id='+cast(@IDAdgFileZIP as varchar(100))+'''> aquí</a>
				</p>
			'

		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacionEncargado,'{ "subject":"'+@subjectZIP+'", "body": "'+@bodyZIP+'"}'

		set @IDNotificacion = @@IDENTITY  
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos) 
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then @EmailAdministradorProyecto else null end  
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacionColaborador
	END
GO
