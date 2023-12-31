USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create the data type
--CREATE TYPE App.dtAdgFiles AS TABLE 
--(
--	[name]		 varchar(max),
--    extension	 varchar(max),
--    pathFile	 varchar(max),
--    relativePath varchar(max),
--    downloadURL	 varchar(max)
--)
--GO

--CREATE table App.tblAdgFiles(
--	IDAdgFile		int not null Identity(1,1)  constraint Pk_AppTblAdgFiles_IDAdgFile primary key,
--	[name]			varchar(max),
--    extension		varchar(max),
--    pathFile		varchar(max),
--    relativePath	varchar(max),
--    downloadURL		varchar(max),
--	requiereAutenticacion bit constraint D_AppTblAdgFiles_requiereAutenticacion default cast(0 as bit)
--)
--GO
--CREATE table App.tblHistorialDescargasAdgFiles(
--	IDHistorialDescargaAdgFile int not null identity(1,1) constraint Pk_AppTblHistorialDescargasAdgFiles_IDHistorialDescargaAdgFile primary key,
--	IDAdgFile int not null constraint Fk_AppTblHistorialDescargasAdgFiles_AppTblAdgFiles_IDAdgFile foreign key references App.tblAdgFiles(IDAdgFile) on delete cascade,
--	IDUsuario int constraint Fk_AppTblHistorialDescargasAdgFiles_SeguridadTblUsuarios_IDUsuario foreign key references Seguridad.tblUsuarios(IDUsuario) on delete cascade,
--	FechaHoraDescarga datetime constraint D_AppTblHistorialDescargasAdgFiles_FechaHoraDescarga default getdate()
--)
--GO
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
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
create proc Evaluacion360.spEntregaDeResultadosEvaluacionEmpleadoYEncargado (
	@files App.dtAdgFiles readonly
) as

	declare
		@filesIndividuales App.dtAdgFiles,
		@filesCompromidos App.dtAdgFiles,
		@Link varchar(max),
		@IDAdgFile int,
		@IDNotificacion int,
		@IDTipoNotificacionColaborador varchar(200) = 'EntregaDeResultadosEvaluacionEmpleado',
		@IDTipoNotificacionEncargado varchar(200) = 'EntregaDeResultadosEvaluacionEmpleadoEncargado',
		@Email varchar(max)
	;

	
	select top 1 @Link = valor 
	from App.tblConfiguracionesGenerales with (nolock)
	where IDConfiguracion = 'Url'


	insert @filesIndividuales([name])
	values(114)
	     ,(115)
	     ,(120)
	     ,(121)
	     ,(122)
	     ,(123)
	     ,(125)
	     ,(126)
	     ,(127)
	     ,(128)
	     ,(129)

	insert @filesCompromidos([name])
	values(130)

	--select *	
	--from @filesIndividuales

	BEGIN -- Email individuales colaboradores
		DECLARE @archive as TABLE
		(
			ActionType		varchar(10),
			IDAdgFile		int,
			[name]			varchar(max),
			extension		varchar(max),
			pathFile		varchar(max),
			relativePath	varchar(max),
			downloadURL		varchar(max),
			requiereAutenticacion bit
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
		   inserted.*
		INTO @archive;

		--SELECT  * FROM  @archive --WHERE ActionType IN ( 'DELETE', 'UPDATE' );

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
			join Evaluacion360.tblEnviarResultadosAColaboradores enviarResultado with (nolock) on enviarResultado.IDEmpleadoProyecto = ep.IDEmpleadoProyecto and enviarResultado.Valor = 1
			join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = ep.IDEmpleado
			left join Seguridad.tblUsuarios u with (nolock) on u.IDEmpleado = e.IDEmpleado
			left join (
				select ce.IDEmpleado
					,lower(ce.[Value]) as Email
					,ce.Predeterminado
					,ROW_NUMBER()OVER(partition by ce.IDEmpleado order by ce.Predeterminado desc) as [ROW]
				from RH.tblContactoEmpleado ce with (nolock)
					join [RH].[tblCatTipoContactoEmpleado] ctce with (nolock) on ctce.IDTipoContacto = ce.IDTipoContactoEmpleado and ctce.Descripcion like '%email%'
				where ce.[Value] is not null
			) c on c.IDEmpleado = e.IDEmpleado and c.[ROW] = 1

		if object_id('tempdb..#tempTemplateEmailsColaboradores') is not null drop table #tempTemplateEmailsColaboradores;

		select top 3
			IDAdgFile,
			IDEmpleado,
			Email,
			[subject] = N'Hola '+Colaborador+', Te entregamos los resultados de la prueba.',
			html = N'
				<p>ANEUDY te hacemos entrega de los resultados de la prueba <b>'+Proyecto+'.</b></p>
				<br />
				<p style=''text-align: center;margin-bottom: 30px;''>
					Descarga el resultado <a style=''font-weight: 600;color: black;cursor: pointer;'' href='''+@Link+'App/download/'+cast(IDAdgFile as varchar(100))+'''> aquí</a>
				</p>
			'
		INTO #tempTemplateEmailsColaboradores
		from #tempEmailsColaboradores

		select @IDAdgFile = min(IDAdgFile) from #tempTemplateEmailsColaboradores
		while exists (select top 1 1 from #tempTemplateEmailsColaboradores where IDAdgFile >= @IDAdgFile)
		begin
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
			SELECT @IDTipoNotificacionColaborador,'{ "subject":"'+[subject]+'", "body": "'+[html]+'"}'
			from #tempTemplateEmailsColaboradores
			where IDAdgFile = @IDAdgFile

			select @Email = Email
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
				,NULL 
			from [App].[tblTiposNotificaciones] tn  
				INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
			where tn.IDTipoNotificacion = @IDTipoNotificacionColaborador
		

			select @IDAdgFile = min(IDAdgFile) from #tempTemplateEmailsColaboradores where IDAdgFile > @IDAdgFile
		end

	END
	select *
	from #tempTemplateEmailsColaboradores
	--select *
	--from Evaluacion360.tblEnviarResultadosAColaboradores

	--select 
	--	e.IDEmpleado, 
	--	e.ClaveEmpleado, 
	--	e.NOMBRECOMPLETO, 
	--	Email = case when c.Email is not null then c.Email else u.Email end, 
	--	c.*
	--from [RH].[tblEmpleadosMaster] e with (nolock)
	--	left join Seguridad.tblUsuarios u with (nolock) on u.IDEmpleado = e.IDEmpleado
	--	left join (
	--		select ce.IDEmpleado
	--			,lower(ce.[Value]) as Email
	--			,ce.Predeterminado
	--			,ROW_NUMBER()OVER(partition by ce.IDEmpleado order by ce.Predeterminado desc) as [ROW]
	--		from RH.tblContactoEmpleado ce with (nolock)
	--			join [RH].[tblCatTipoContactoEmpleado] ctce with (nolock) on ctce.IDTipoContacto = ce.IDTipoContactoEmpleado and ctce.Descripcion like '%email%'
	--		where ce.[Value] is not null
	--	) c on c.IDEmpleado = e.IDEmpleado and c.[ROW] = 1
	--order by e.IDEmpleado

	-- [RH].[tblCatTipoContactoEmpleado]
GO
