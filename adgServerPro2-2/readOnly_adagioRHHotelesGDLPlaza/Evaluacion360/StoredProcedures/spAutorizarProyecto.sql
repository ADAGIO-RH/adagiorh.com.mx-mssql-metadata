USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Autoriza un proyecto y envio notificaciones a los evaluadores.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-04-25			Aneudy Abreu	Se corregió el bug que enviaba la activación de la cuenta del 
									empleado al evaluador.
2021-07-08			Aneudy Abreu	Se modificó el Subject de los correos
***************************************************************************************************/
-- Catálogo de KEY para los Emails:
/*
	* Información Colaboradores y Evaluadores
	NombreColaborador			: Hace referencia al nombre de quién será evaluado.
	NombreEvaluador				: Hace referencia al nombre del evaluador de la prueba.
	RazonSocialEmpleado			: Hace referencia a la empresa que pertenece el colaborador

	* Información de Contactos, Administradores y Auditores del proyecto
	AdministradorProyecto			: Hace referencia al Nombre e Email de la persona que administra el proyecto
	AuditorProyecto					: Hace referencia al Nombre e Email de la persona que audita el proyecto
	ContactoProyecto				: Hace referencia al Nombre e Email de la persona que tendrá la contacto directo con los colaboradores en el proyecto

	* Información del proyecto
	FechaLimitePrueba			: Hace referencia a la fecha máxima que tendrá disponible el Colaborador/Evaluador para responder la prueba.
	LinkPrueba					: Hace referencia al enlace directo para responder la prueba 

*/

-- [Evaluacion360].[spAutorizarProyecto] 28,1

CREATE PROC [Evaluacion360].[spAutorizarProyecto](
	 @IDProyecto int
	 ,@IDUsuario int
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spAutorizarProyecto]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblEstatusProyectos]',
		@Accion		varchar(20)	= 'AUTORIZANDO PRUEBA',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max),
		@NombrePrueba	varchar(max)
	;
--DECLARE @IDProyecto int = 37;

	DECLARE 
		@IDEmpleadoProyecto			int = 0
		,@IDEvaluacionEmpleado		int = 0
		,@IDTipoRelacion			int = 0
		,@IDNotificacion			int = 0
		,@IDEmpleado				int = 0
		,@IDEvaluador				int = 0
		,@NombreColaborador			varchar(255)
		,@NombreEvaluador			varchar(255)	
		,@RazonSocialEmpleado		varchar(255)	
		,@NombreContactoProyecto	varchar(255)		
		,@EmailContactoProyecto		varchar(255)	
		,@FechaLimitePrueba			date
		,@LinkPrueba				varchar(max)	
	
		,@EmailColaborador		varchar(1000)					 
		,@EmailEvaluador		varchar(1000)	

		,@AdministradorProyecto		varchar(255)
		,@AuditorProyecto			varchar(255)
		,@ContactoProyecto			varchar(255)

		,@IdiomaSQL varchar(100) = 'Spanish'	
		,@HTMLListOut varchar(max)
		,@xmlParametros varchar(max)		
		,@LabelBotton varchar(50) = ''

		,@UsuarioActivo bit = 0
		,@ActiveAccountUrl varchar(max)

		,@IDUsuarioActivar int = 0
		,@key varchar(max)
		,@cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
	;

	select @InformacionExtra = a.JSON 
	from (
		select IDProyecto
			, Nombre
			, Descripcion
			, FORMAT(isnull(FechaCreacion, GETDATE()),'dd/MM/yyyy') as FechaCreacion
			, Progreso
		from Evaluacion360.tblCatProyectos p with (nolock)
		where IDProyecto = @IDProyecto
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	select top 1 @LinkPrueba = valor 
	from App.tblConfiguracionesGenerales with (nolock)
	where IDConfiguracion = 'Url'

	select top 1 @ActiveAccountUrl = valor 
	from App.tblConfiguracionesGenerales with (nolock) 
	where IDConfiguracion = 'ActiveAccountUrl'

	SET LANGUAGE @IdiomaSQL;

	-- Valida si exisiste preguntas en la prueba, si no existen entonces envia un mensaje de error!
	if not exists (select top 1 1 
					from Evaluacion360.tblCatGrupos cg with (nolock)
						join Evaluacion360.tblCatPreguntas cp with (nolock) on cg.IDGrupo = cp.IDGrupo
					where cg.TipoReferencia = 1 and cg.IDReferencia = @IDProyecto) 
	begin
		set @Mensaje = 'Agrega preguntas a la pruebas antes de autorizarla!'

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra

		raiserror(@Mensaje,16,1);
		return;
	end;

	EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra


	SELECT 
		@AdministradorProyecto	= CASE WHEN tep.IDCatalogoGeneral	= 1 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @AdministradorProyecto end
		,@AuditorProyecto		= CASE WHEN tep.IDCatalogoGeneral	= 2 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @AuditorProyecto end
		,@ContactoProyecto		= CASE WHEN tep.IDCatalogoGeneral	= 3 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @ContactoProyecto end
		,@NombreContactoProyecto= CASE WHEN tep.IDCatalogoGeneral	= 3 THEN coalesce(tep.Nombre,'') ELSE @NombreContactoProyecto end
		,@EmailContactoProyecto	= CASE WHEN tep.IDCatalogoGeneral	= 3 THEN coalesce(tep.Email,'') ELSE @EmailContactoProyecto end
	from [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
	WHERE tep.IDProyecto = @IDProyecto

	select 
		@NombrePrueba = Nombre,
		@FechaLimitePrueba = ISNULL(FechaFin, GETDATE())
 	from Evaluacion360.tblCatProyectos with (nolock)
	where IDProyecto = @IDProyecto

	if object_id('tempdb..#tempEmailEvaluadoresEnviados') is not null drop table #tempEmailEvaluadoresEnviados;

	create table #tempEmailEvaluadoresEnviados(
		IDEvaluador int  
	);

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

	IF object_id('tempdb..#tempAutoEva') IS NOT NULL DROP TABLE #tempAutoEva;

	SELECT tep.IDEmpleadoProyecto
		,tee.IDEvaluacionEmpleado
		,tep.IDProyecto
		,tep.IDEmpleado
		,tem.ClaveEmpleado
		,tem.Nombre
		,tem.Nombre+' '+coalesce(tem.Paterno, '')+' '+coalesce(tem.Materno, '') AS NombreColaborador
		,tem.Empresa
		,temEva.Nombre+' '+coalesce(temEva.Paterno, '')+' '+coalesce(temEva.Materno, '') AS NombreEvaluador
		,tuEmp.Email  as EmailColaborador	 
		,tuEva.Email  as EmailEvaluador		 
		,tee.IDTipoRelacion
		,tee.IDEvaluador
		,'' AS LinkPrueba
	INTO #tempAutoEva
	FROM Evaluacion360.tblEmpleadosProyectos tep		with (nolock)
		JOIN Evaluacion360.tblEvaluacionesEmpleados tee with (nolock) ON tep.IDEmpleadoProyecto = tee.IDEmpleadoProyecto
		JOIN RH.tblEmpleadosMaster tem		with (nolock)	ON tep.IDEmpleado	= tem.IDEmpleado
		JOIN RH.tblEmpleadosMaster temEva	with (nolock)	ON tee.IDEvaluador	= temEva.IDEmpleado
		LEFT JOIN Seguridad.tblUsuarios tuEmp with (nolock) ON tem.IDEmpleado	= tuEmp.IDEmpleado 
		LEFT JOIN Seguridad.tblUsuarios tuEva with (nolock) ON temEva.IDEmpleado = tuEva.IDEmpleado 
	WHERE tep.IDProyecto = @IDProyecto --AND tee.IDTipoRelacion = 4

	print 'Notificación: Invitación a realizar la autoevaluación'
	
	SELECT @IDEvaluacionEmpleado = min(tae.IDEvaluacionEmpleado) FROM #tempAutoEva tae

	WHILE exists(SELECT TOP 1 1 FROM #tempAutoEva tae WHERE tae.IDEvaluacionEmpleado >= @IDEvaluacionEmpleado)
	BEGIN
		SELECT 
			 @NombreColaborador			= tae.Nombre
			,@IDEmpleado				= tae.IDEmpleado
			,@RazonSocialEmpleado		= tae.Empresa				
			,@IDEvaluador				= tae.IDEvaluador
			,@NombreEvaluador			= tae.NombreEvaluador
			,@IDTipoRelacion			= tae.IDTipoRelacion
			
			,@EmailColaborador			= tae.EmailColaborador
			,@EmailEvaluador			= tae.EmailEvaluador

		--	,@FechaLimitePrueba			= getdate()
			,@LabelBotton				= 'Ir a la evaluación'
		--	,@LinkPrueba				= tae.LinkPrueba	
		from #tempAutoEva tae
		where tae.IDEvaluacionEmpleado = @IDEvaluacionEmpleado;

		-- Se valida si el colaborador está Activo y su usuairo no se encuentr activo.
		if exists(select top 1 1 
					from Seguridad.tblUsuarios u with (nolock) 
						join RH.tblEmpleadosMaster e on u.IDEmpleado = e.IDEmpleado
					where u.IDEmpleado = @IDEvaluador and isnull(u.Activo,cast(0 as bit)) = 0 and isnull(e.Vigente,cast(0 as bit)) = 1) 
 		begin

			set @key = REPLACE(NEWID(),'-','')+''+REPLACE(NEWID(),'-','');

			select top 1 @IDUsuarioActivar = IDUsuario
			from Seguridad.tblUsuarios with (nolock) 
			where IDEmpleado = @IDEvaluador

			insert [Seguridad].TblUsuariosKeysActivacion(IDUsuario,ActivationKey,AvaibleUntil,Activo)
			select @IDUsuarioActivar,@key,dateadd(day,30,getdate()),1

			select 
				@LabelBotton = case when @IDTipoRelacion <> 4 then 'Activa tu cuenta y realiza la evaluación' else  'Activa tu cuenta y realiza tu Auto Evaluación' end
				,@LinkPrueba = @ActiveAccountUrl+@key

		end;

		--SELECT TOP 1 @Email = tce.[Value]
		--FROM RH.tblContactoEmpleado tce
		--WHERE tce.IDTipoContactoEmpleado = 1 AND tce.IDEmpleado = @IDEmpleado

		delete from #tempParams;

		insert #tempParams(Variable, Valor)
		values('NombreEvaluador',coalesce(@NombreEvaluador,''))
				,('RazonSocialEmpleado',coalesce(@RazonSocialEmpleado,''))
				,('AdministradorProyecto',coalesce(@AdministradorProyecto,''))
				,('ContactoProyecto',coalesce(@ContactoProyecto,''))
				,('NombreContactoProyecto',coalesce(@NombreContactoProyecto,''))
				,('EmailContactoProyecto',coalesce(@EmailContactoProyecto,''))
				,('AuditorProyecto',coalesce(@AuditorProyecto,''))
				,('FechaLimitePrueba',convert(varchar(11), @FechaLimitePrueba,100))
				,('LinkPrueba',coalesce(@LinkPrueba,''))
				,('NombreEmpresa',coalesce('Adagio Informática Integral',''))
				,('LabelBotton',coalesce(@LabelBotton,''))
				

		IF (@IDTipoRelacion <> 4)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 
							FROM #tempEmailEvaluadoresEnviados 
							WHERE #tempEmailEvaluadoresEnviados.IDEvaluador = @IDEvaluador)
			BEGIN
				set @HTMLListOut  = '<ul class=''leaders''>'

				select @HTMLListOut = @HTMLListOut + '<li>'+ NombreColaborador +'</li>'
				FROM #tempAutoEva
				where IDEvaluador = @IDEvaluador AND #tempAutoEva.IDTipoRelacion <> 4

				set @HTMLListOut = @HTMLListOut+'</ul>'
			
				insert #tempParams(Variable, Valor)
				Values('ListadoPersonasPorEvaluar',coalesce(@HTMLListOut,''))
						,('Subject',coalesce(@NombrePrueba,'') +' - Evaluación de desempeño a realizar')
			 
				INSERT #tempEmailEvaluadoresEnviados(IDEvaluador)
				values(@IDEvaluador)

				--set @xmlParametros = (select * 
				--	from #tempParams
				--	FOR XML path, ROOT
				--	);
				
				IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot
	
				SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
							FROM #tempParams c
							FOR XML PATH(''), TYPE
							).value('.', 'NVARCHAR(MAX)') 
						,1,1,'')

				set @query = 'SELECT  ' + @cols + ' 
							into ##tempParamsPivot
							from (
								select Variable
									,Valor
								from #tempParams
							) x
							pivot 
							(
								max(Valor)
								for Variable in (' + @cols + ')
							) p '

				execute(@query)

				select @xmlParametros = a.JSON from ##tempParamsPivot b
					Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

				if (len(coalesce(@EmailEvaluador,'')) > 0)
				begin
					insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
					select 'InvitacionRealizarEvaluaciones',@xmlParametros
			
					set @IDNotificacion = @@IDENTITY;

					insert [App].[tblEnviarNotificacionA](  
							IDNotifiacion  
							,IDMedioNotificacion  
							,Destinatario)  
					select @IDNotificacion  
						,templateNot.IDMedioNotificacion  
						,case when templateNot.IDMedioNotificacion = 'Email' then @EmailEvaluador else null end  
					from [App].[tblTiposNotificaciones] tn with (nolock)  
						join [App].[tblTemplateNotificaciones] templateNot with (nolock) on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
					where tn.IDTipoNotificacion = 'InvitacionRealizarEvaluaciones' 
				end;
			END
		END else 
		BEGIN
			--set @xmlParametros = (select * 
			--			from #tempParams
			--			FOR XML path, ROOT
			--			);
			
			IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot
	
			insert #tempParams(Variable, Valor)
			Values('Subject',coalesce(@NombrePrueba,'') +' - '+'Realiza tu autoevaluación')

			SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
						FROM #tempParams c
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

			set @query = 'SELECT  ' + @cols + ' 
							into ##tempParamsPivot
							from (
								select Variable
									, Valor
								from #tempParams
							) x
							pivot 
							(
								max(Valor)
								for Variable in (' + @cols + ')
							) p '

			execute(@query)

			select @xmlParametros = a.JSON from ##tempParamsPivot b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

			if (len(coalesce(@EmailColaborador,'')) > 0)							
			begin
				insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
				select 'InvitacionRealizarAutoevaluacion',@xmlParametros
			
				set @IDNotificacion = @@IDENTITY  ;

				insert [App].[tblEnviarNotificacionA](  
						IDNotifiacion  
						,IDMedioNotificacion  
						,Destinatario)  
				select @IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,case when templateNot.IDMedioNotificacion = 'Email' then @EmailColaborador else null end  
				from [App].[tblTiposNotificaciones] tn with (nolock)  
					join [App].[tblTemplateNotificaciones] templateNot with (nolock) on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				where tn.IDTipoNotificacion = 'InvitacionRealizarAutoevaluacion'
			end;
		END;

		--	-- Validamos si tiene email el colaborador
		--IF (len(coalesce(@Email,'')) > 0)
		--BEGIN
		--END ELSE 
		--BEGIN
		--	PRINT 'El colaborador no tiene email'
		--end;

		SELECT @IDEvaluacionEmpleado = min(tae.IDEvaluacionEmpleado) FROM #tempAutoEva tae WHERE tae.IDEvaluacionEmpleado > @IDEvaluacionEmpleado
	END;

--SELECT * FROM #tempAutoEva
-- Notificación: Invitación a realizar las Demás tipos de pruebas:
GO
