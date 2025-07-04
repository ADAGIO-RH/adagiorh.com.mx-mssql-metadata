USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: <Autor,varchar,Nombre>
** Email			: <Email,varchar,@adagio.com.mx>
** FechaCreacion	: <FechaCreacion,Date,Fecha>
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROCEDURE [Reclutamiento].[spINotificacionesActivarCuentaCandidato] ( 
	@IDCandidato int,
	@Key varchar(max)
)  AS  
BEGIN  

    declare 
		@IDNotificacion int
		,@IDTipoNotificacion varchar (255)                    
		,@htmlbody varchar (4000)                    
		,@subject varchar (4000)   
		,@NombreEmpresaReclutamiento varchar(max)
		,@NombreCandidato varchar(max)
		,@EmailCandidato varchar(max)
		,@LinkActivacion varchar(max)
        ,@TIPO_REFERENCIA_CANDIDATO VARCHAR(255)
	;

    set @TIPO_REFERENCIA_CANDIDATO='[Reclutamiento].[tblCandidatos]'

    
	
	select @LinkActivacion = Valor from [App].[tblConfiguracionesGenerales] WITH (nolock) where IDConfiguracion = 'Url'    
    
	set @LinkActivacion = @LinkActivacion+'Careers/ActivarCuenta?key='+coalesce(@Key, '')
	-- https://appserviceadagiorh.azurewebsites.net/Careers/ActivarCuenta?key=

	select @NombreEmpresaReclutamiento=Valor  from App.tblConfiguracionesGenerales where IDConfiguracion='NombreEmpresaReclutamiento'
	select @NombreCandidato = Nombre, @EmailCandidato=Email from Reclutamiento.tblCandidatos where IDCandidato=@IDCandidato

    set @IDTipoNotificacion='ReclutamientoActivarCuentaCandidato'
    set @subject='¡Activa tu cuenta en nuestra bolsa de trabajo para empezar a buscar empleo!'
    set @htmlbody =N'
		<p>Estimado/a %s,</p>
		<br>
		<p>¡Bienvenido/a a nuestra bolsa de trabajo! Nos complace tenerte como parte de nuestra comunidad de búsqueda de empleo y ayudarte en tu camino hacia la consecución de tus objetivos profesionales.</p>
		<br>
		<p>Para comenzar, por favor activa tu cuenta haciendo clic en el siguiente enlace: <a href=''%s''>Activar cuenta</a>. Una vez que hayas activado tu cuenta, podrás crear una contraseña segura y personalizada para acceder a tu perfil y comenzar a explorar las oportunidades laborales que tenemos para ofrecerte.</p>
		<br>
		<p>Recuerda completar tu perfil con tu experiencia y habilidades para destacar ante los empleadores y aumentar tus posibilidades de ser contratado/a. Además, te recomendamos que mantengas tu perfil actualizado y revises regularmente las ofertas de empleo que te enviamos para asegurarte de no perderte ninguna oportunidad.</p>
		<br>
		<p>Si tienes alguna pregunta o necesitas ayuda en cualquier momento, no dudes en ponerte en contacto con nuestro equipo de soporte al cliente. Estamos aquí para ayudarte en todo lo que necesites.</p>
		<br>
		<p>¡Gracias por unirte a nuestra comunidad de búsqueda de empleo! Estamos ansiosos por ayudarte a avanzar en tu carrera profesional.</p>
		<br>
		<p>Saludos cordiales,</p>
		
		<p>%s</p>
	'  
	            		
    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)
        
    set @IDNotificacion=SCOPE_IDENTITY();
        
    --USUARIOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)    
    select  @IDNotificacion,'Email',@EmailCandidato,0,
    '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody, 
															@NombreCandidato,
                                                            @LinkActivacion,
                                                            @NombreEmpresaReclutamiento
                                                        )+'"}',
                                                        @TIPO_REFERENCIA_CANDIDATO,@IDCandidato,NULL  

    
END
GO
