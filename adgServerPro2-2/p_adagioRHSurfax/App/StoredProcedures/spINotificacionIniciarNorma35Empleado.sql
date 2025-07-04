USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : 
** Email   : ?
** FechaCreacion : 2022-02-02  
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2025-03-20          Jose Vargas         Al insertar a la tabla  `[App].[tblEnviarNotificacionA]` se agregan los valores 
                                        `IDReferencia`,`TipoReferencia`,`IDusuario` esto para el rastreo de correos.
                                        
***************************************************************************************************/  
CREATE PROCEDURE [App].[spINotificacionIniciarNorma35Empleado](
	@IDEncuestaEmpleado int = 0,
	@IDEncuesta int = 0,
	@IDUsuario int
)
AS
BEGIN
	--------------------------------------------------
		--NOTIFICACIÓN POR EMAIL
		--------------------------------------------------'
        declare @TIPO_REFERENCIA_NORMA35 varchar(100)
		DECLARE @Parametros TABLE (
				identityValue int not null identity(1,1)
				,IDEmpleado int
				,IDEncuesta int
				,IDEncuestaEmpleado int
				,NombreEmpresa Varchar(255)
				,FechaFin Date
				,NombreEmpleado Varchar(255)
				,Email Varchar(255)
				,Url Varchar(max)
				,[subject] VARCHAR(max)
				,[body] VARCHAR(max)
				,Params Varchar(max)
				,IDNotificacion int
			);

		set @TIPO_REFERENCIA_NORMA35='[Norma35].[tblEncuestas]';

		DECLARE @Asunto VARCHAR(255) = 'Hola [NombreEmpleado], has sido invitado a responder una encuesta'
			, @Contenido VARCHAR(MAX) = 
			'<pre class="notranslate" lang="Asunto:"><code class="notranslate">Estimados colaboradores,<br /><br />En [NombreEmpresa], nos preocupamos por su bienestar y estamos comprometidos con crear un entorno laboral saludable y seguro para todos. Como parte de nuestros esfuerzos para lograr este objetivo, hemos implementado la norma 035 para identificar y prevenir los factores de riesgo psicosocial en nuestro centro de trabajo.<br /><br />Queremos escuchar su opini&oacute;n y conocer su experiencia laboral para poder mejorar a&uacute;n m&aacute;s nuestro ambiente laboral. Por eso, los invitamos a participar en esta encuesta, que nos ayudar&aacute; a identificar &aacute;reas de mejora y a implementar las soluciones necesarias para garantizar su bienestar y el de sus compa&ntilde;eros.<br /><br />La encuesta es confidencial y solo tomar&aacute; unos minutos de su tiempo. Sus respuestas son muy importantes para nosotros y nos ayudar&aacute;n a tomar decisiones informadas para mejorar su ambiente laboral.<br /><br />Para acceder a la encuesta, simplemente haga clic en el siguiente enlace [Link]. Recuerde que la fecha l&iacute;mite para completar la encuesta es [FechaFin].<br /><br />Gracias de antemano por su participaci&oacute;n y colaboraci&oacute;n en este importante proceso.<br /><br />Saludos cordiales,<br />[NombreDelRemitente]</code></pre>'

		DECLARE @NombreEmpresa	VARCHAR(255)
			, @FechaFin			VARCHAR(255)
			, @NombreRemitente	VARCHAR(255)
			, @NombreEmpleado	VARCHAR(255)
			, @Email			VARCHAR(255)
			, @URL				VARCHAR(max)
			, @identityNotificaciones int
			, @IDNotificacion int
			;

		SELECT TOP 1 @URL = Valor+'Login/Index?idaplicacion=Norma35' 
		FROM app.tblConfiguracionesGenerales with(nolock) 
		WHERE IDConfiguracion = 'Url'

		insert into @Parametros(IDEmpleado,IDEncuesta,IDEncuestaEmpleado,NombreEmpresa,FechaFin,NombreEmpleado,Email,Url,[subject],[body])
		SELECT EE.IDEmpleado,
			E.IDEncuesta,
			EE.IDEncuestaEmpleado,
			EM.Empresa,
			E.FechaFin,
			em.NombreCompleto,
			[Utilerias].[fnGetCorreoEmpleado](ee.IDEmpleado, 0, 'IniciarNorma035'),
			@URL,
			@Asunto,
			@Contenido
		FROM [Norma35].[tblEncuestas] E	WITH(nolock)
			inner join [Norma35].[tblEncuestasEmpleados] EE WITH(nolock)
				on E.IDEncuesta = EE.IDEncuesta
			inner join RH.tblEmpleadosMaster em with(nolock)
				on EE.IDEmpleado = EM.IDEmpleado
		WHERE ((E.IDEncuesta = @IDEncuesta)OR (ISNULL(@IDEncuesta,0)= 0))
		and ((EE.IDEncuestaEmpleado = ISNULL(@IDEncuestaEmpleado,0) OR (ISNULL(@IDEncuestaEmpleado,0) = 0)))

	
	
		UPDATE @Parametros
			SET body = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(body,'[NombreEmpresa]',NombreEmpresa),'[FechaFin]',FechaFin),'[Link]',URL),'[NombreDelRemitente]',NombreEmpresa),'[NombreEmpleado]',	NombreEmpleado),
				[subject] = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([subject],'[NombreEmpresa]',NombreEmpresa),'[FechaFin]',FechaFin),'[Link]',URL),'[NombreDelRemitente]',NombreEmpresa),'[NombreEmpleado]',	NombreEmpleado)
		
		
		UPDATE @Parametros
			set Params = (SELECT [subject]
						, body
					FOR JSON PATH
						, INCLUDE_NULL_VALUES
						, WITHOUT_ARRAY_WRAPPER
					)
		

		--select * from @Parametros

		SET @identityNotificaciones = (SELECT MIN(IdentityValue) from @Parametros where Email is not null)
		While(@identityNotificaciones <= (SELECT MAX(IdentityValue) from @Parametros where Email is not null))
		BEGIN

			INSERT INTO [App].[tblNotificaciones] (IDTipoNotificacion, Parametros)
			SELECT 'IniciarNorma035', p.Params
			FROM @Parametros p
			WHERE identityValue = @identityNotificaciones

			SET @IDNotificacion = @@IDENTITY

			UPDATE @Parametros
				set IDNotificacion = @IDNotificacion
			WHERE identityValue = @identityNotificaciones

			SET @identityNotificaciones = (SELECT MIN(IdentityValue) from @Parametros where Email is not null and identityValue > @identityNotificaciones)

		END

		-- Insertar las filas en la tabla utilizando la cláusula OUTPUT para capturar los valores de @@IDENTITY	
		INSERT [App].[tblEnviarNotificacionA] (
			IDNotifiacion
			, IDMedioNotificacion
			, Destinatario
            ,TipoReferencia
            ,IDReferencia
            ,IDUsuario            
			)
		SELECT p.IDNotificacion
			, templateNot.IDMedioNotificacion
			, p.Email
            ,@TIPO_REFERENCIA_NORMA35
            ,@IDEncuesta
            ,u.IDUsuario
		FROM @Parametros p
		cross apply [App].[tblTiposNotificaciones] tn with(nolock)
		JOIN [App].[tblTemplateNotificaciones] templateNot with(nolock) ON tn.IDTipoNotificacion = templateNot.IDTipoNotificacion
        left join Seguridad.tblUsuarios u on u.IDEmpleado=p.IDEmpleado
		WHERE tn.IDTipoNotificacion = 'IniciarNorma035'
		and p.IDNotificacion is not null
		and [Utilerias].[fsValidarEmail](isnull(p.Email,'')) = 1
		
END
GO
