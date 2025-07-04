USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--32
--33
 -- App.spINotificacionNuevoCandidato 32
CREATE proc [App].[spINotificacionNuevoCandidato] (
	@IDCandidatoPlaza int
)
as
	declare 
		@IDReclutador int,
		@IDCliente int,
		@NombreReclutador	varchar(255),
		@EmailReclutador	varchar(255),
		@NombreCandidato	varchar(255),
		@EmailCandidato		varchar(255),
		@IDPuesto			int,
		@NombreVacante		varchar(max),
		@NombreEmpresa		varchar(max),
        @IDUsuarioRecludator int,
		@EmailTemplates varchar(max),
		@Subject		varchar(MAX),
		@Template		varchar(MAX),

		@IDIdioma varchar(10),
		@IDUsuario int,

		@Key varchar(max),
		@Value varchar(max),

		@IDTipoNotificacion varchar(255) = 'ReclutamientoNuevoCandidato',
		@IDNotificacion int,

		@footer varchar(max) = '<p style="font-size: 10px">© Adagio Informática Integral SC. La Villa 1996, CP 45500, Guadalajara Jalisco, México</p>',
		@valor varchar(max)
	    ,@TIPO_REFERENCIA_CANDIDATO_PLAZA VARCHAR(255)
	;

    set @TIPO_REFERENCIA_CANDIDATO_PLAZA='[Reclutamiento].[tblCandidatoPlaza]'


	set @EmailTemplates = N'{
			"esmx": {
				"subject": "Nuevo Candidato Registrado para {NombreVacante}",
				"body": "Estimado/a {ReclutadorNombreColaborador}. <br /> <br />Es un placer informarte que hemos recibido la inscripción de un nuevo candidato para la vacante de {NombreVacante} en {NombreEmpresa}. A continuación, te proporcionamos algunos detalles clave: <br /> <br />  <b>Nombre del Candidato:</b> {NombreCandidato} <br /> <b>Correo Electrónico:</b> {EmailCandidato}<br /><br />Te animamos a revisar el perfil adjunto del candidato y considerar si cumple con los requisitos de la posición. Si deseas obtener más información o coordinar una entrevista, no dudes en contactar al candidato directamente. <br />Estamos seguros de que este candidato podría ser una adición valiosa a nuestro equipo, y esperamos que esta coincidencia sea beneficiosa para ambas partes. <br /> Quedamos a tu disposición para cualquier consulta o asistencia adicional que puedas necesitar. <br /><br />¡Gracias por tu continuo compromiso y dedicación en el proceso de selección!"
			},
			"enus": {
				"subject": "New Candidate Registered for {NombreVacante} Position",
				"body": "Dear {ReclutadorNombreColaborador}. <br /> <br />We are pleased to inform you that we have received a new application for the {NombreVacante} position at {NombreEmpresa}. Below are some key details: <br /> <br /><b>Candidate''s Name:</b> {NombreCandidato} <br /> <b>Email Address:</b> {EmailCandidato} <br /><br />We encourage you to review the attached candidate profile and assess if they meet the requirements of the position. If you would like to gather more information or schedule an interview, feel free to reach out to the candidate directly. <br />We believe this candidate could be a valuable addition to our team, and we hope this match proves beneficial for both parties. <br /> We remain at your disposal for any further questions or assistance you may require. <br /> <br />Thank you for your ongoing commitment and dedication to the selection process!\n\n"}}'

	declare @templateData as table (
		[Key] varchar(max),
		[Value] varchar(max)
	)

	select @footer = isnull(Valor, @footer) from App.tblConfiguracionesGenerales where IDConfiguracion = 'FooterEmails' 

	select 
		@IDCliente			= p.IDCliente
		,@IDReclutador		= cp.IDReclutador
		,@NombreCandidato	= coalesce(c.Nombre, '')+' '+coalesce(c.Paterno, '')
		,@EmailCandidato	= c.Email
		,@IDPuesto			= p.IDPuesto
		,@NombreEmpresa		= (
			select 
				isnull((select emp.NombreComercial from RH.tblEmpresa emp		where emp.IDEmpresa = config.Valor), '[SIN ASIGNAR]') 
			from OPENJSON(p.Configuraciones, '$') 
			with (
				IDTipoConfiguracionPlaza varchar(max), 
				Valor int
			) as config
			where IDTipoConfiguracionPlaza = 'Empresa'
		)
	from Reclutamiento.tblCandidatoPlaza cp
		join Reclutamiento.tblCandidatos c	on c.IDCandidato = cp.IDCandidato
		join RH.tblCatPlazas p				on p.IDPlaza = cp.IDPlaza
		join RH.tblCatPuestos puesto		on puesto.IDPuesto = p.IDPuesto
	where cp.IDCandidatoPlaza = @IDCandidatoPlaza

	if (isnull(@IDReclutador, 0) != 0)
	begin
		select 
			@IDUsuario = IDUsuario
		from Seguridad.tblUsuarios
		where IDEmpleado = @IDReclutador

		select 
			@NombreReclutador = e.NOMBRECOMPLETO,
			@EmailReclutador = Utilerias.fnGetCorreoEmpleado(e.IDEmpleado, null, @IDTipoNotificacion),
            @IDUsuarioRecludator= u.IDUsuario
		from RH.tblEmpleadosMaster e
        left join Seguridad.tblUsuarios u on u.IDEmpleado= e.IDEmpleado
		where e.IDEmpleado = @IDReclutador

		INSERT @templateData
		values 
			('ReclutadorNombreColaborador', @NombreReclutador)
			,('ReclutadorEmail', @EmailReclutador)

		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
	end else 
	begin
		INSERT @templateData
		SELECT 
			[Key],
			[Value]
		FROM RH.fnBuscaReclutadorDefaultPorCliente(@IDCliente)

		select top 1 @EmailReclutador = [Value]
		from @templateData
		where [Key] = 'ReclutadorEmail' 

		set @IDIdioma = 'en-US'
	end

	select 
		@NombreVacante = JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
	from RH.tblCatPuestos
	where IDPuesto = @IDPuesto

	insert @templateData
	values
		('NombreVacante', @NombreVacante)
		,('NombreCandidato', @NombreCandidato)
		,('EmailCandidato', @EmailCandidato)
		,('NombreEmpresa', @NombreEmpresa)

	select 
		@Subject = JSON_VALUE(@EmailTemplates, FORMATMESSAGE('$.%s.subject', lower(replace(@IDIdioma, '-','')))),
		@Template= JSON_VALUE(@EmailTemplates, FORMATMESSAGE('$.%s.body', lower(replace(@IDIdioma, '-',''))))

	SET @Subject = REPLACE(@Subject, '{NombreVacante}', @NombreVacante)

	select @Key = min([key]) from @templateData

	while exists (select top 1 1 from @templateData where [key] >= @key)
	begin
		select @Value = [Value] from @templateData where [key] = @key

		SET @Template = REPLACE(@Template, '{'+@Key+'}', @Value)

		select @Key = min([key]) from @templateData where [key] > @key
	end

	set @valor = (
		select *
		from (
			select 
				@Subject as [subject],
				@Template as body,
				@footer as footer
		) info
		for json auto, without_array_wrapper
	)

	if ((select Utilerias.fsValidarEmail(@EmailReclutador)) = 1)
	begin
		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros, IDIdioma)  
		SELECT @IDTipoNotificacion, @valor, @IDIdioma

		set @IDNotificacion = @@IDENTITY  
	
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos
			,IDTipoAdjunto
            ,TipoReferencia
            ,IDReferencia
            ,IDUsuario
		)  
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then @EmailReclutador else null end  
			,null
			,null
            ,@TIPO_REFERENCIA_CANDIDATO_PLAZA
            ,@IDCandidatoPlaza
            ,@IDUsuarioRecludator
		from [App].[tblTiposNotificaciones] tn  
			join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				and isnull(templateNot.IDIdioma,'es-MX') = @IDIdioma
		where tn.IDTipoNotificacion = @IDTipoNotificacion
	end
GO
