USE [p_adagioRHIndustrialMefi]
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
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-04-25			Aneudy Abreu		Se corregió el bug que enviaba la activación de la cuenta del 
										empleado al evaluador.
2021-07-08			Aneudy Abreu		Se modificó el Subject de los correos
2023-08-17			Aneudy Abreu		Cambios para personalizar las notificaciones de Clima Laboral
2024-10-21			Alejandro Paredes	Se elimina flujo anterior para enviar emails
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

CREATE   PROC [Evaluacion360].[spAutorizarProyecto](
	 @IDProyecto	INT
	 , @IDUsuario	INT
) AS
	DECLARE
		@OldJSON					VARCHAR(MAX) = ''
		, @NewJSON					VARCHAR(MAX)
		, @NombreSP					VARCHAR(MAX) = '[Evaluacion360].[spAutorizarProyecto]'
		, @Tabla					VARCHAR(MAX) = '[Evaluacion360].[tblEstatusProyectos]'
		, @Accion					VARCHAR(20)	 = 'AUTORIZANDO PRUEBA'
		, @Mensaje					VARCHAR(MAX)
		, @InformacionExtra			VARCHAR(MAX)		
		, @IDTipoProyecto			INT = 0
		-- TIPOS PROYECTOS
		, @EVALUACION_360			INT = 1
		, @EVALUACION_DESEMPENO		INT = 2
		, @EVALUACION_CLIMA_LABORAL INT = 3
		, @EVALUACION_ENCUESTA		INT = 4
		;


	SELECT @InformacionExtra = A.JSON
	FROM (
		SELECT IDProyecto
				, Nombre
				, Descripcion
				, FORMAT(ISNULL(FechaCreacion, GETDATE()), 'dd/MM/yyyy') AS FechaCreacion
				, Progreso
		FROM Evaluacion360.tblCatProyectos P WITH(NOLOCK)
		WHERE IDProyecto = @IDProyecto
	) B
		CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT B.* FOR XML RAW))) A


	-- OBTENEMOS EL TIPO DEL PROYECTO
	SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto;
	
	
	-- ***** VALIDACION *****

	-- SI EL PROYECTO ES EVALUACION DE DESEMPEÑO NO EVALUA SI EXISTEN PREGUNTAS DIRECTAMENTE EN EL PROYECTO
	IF(@IDTipoProyecto != @EVALUACION_DESEMPENO)
		BEGIN
			-- VALIDA SI EXISTEN PREGUNTAS EN LA PRUEBA, SI NO EXISTEN ENTONCES ENVIA UN MENSAJE DE ERROR			
			IF NOT EXISTS 
			(
				SELECT TOP 1 1 
				FROM Evaluacion360.tblCatGrupos CG WITH (NOLOCK)
					JOIN Evaluacion360.tblCatPreguntas CP WITH (NOLOCK) ON CG.IDGrupo = CP.IDGrupo
				WHERE CG.TipoReferencia = 1 AND CG.IDReferencia = @IDProyecto
			) 
			BEGIN				
				SET @Mensaje = 'Agrega preguntas a la pruebas antes de autorizarla!'
				EXEC [Auditoria].[spIAuditoria]
					@IDUsuario				= @IDUsuario
					,	@Tabla				= @Tabla
					,	@Procedimiento		= @NombreSP
					,	@Accion				= @Accion
					,	@NewData			= @NewJSON
					,	@OldData			= @OldJSON
					,	@Mensaje			= @Mensaje
					,	@InformacionExtra	= @InformacionExtra
				RAISERROR(@Mensaje, 16, 1);
				RETURN;
			END;
		END

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario			= @IDUsuario
		, @Tabla			= @Tabla
		, @Procedimiento	= @NombreSP
		, @Accion			= @Accion
		, @NewData			= @NewJSON
		, @OldData			= @OldJSON
		, @Mensaje			= @Mensaje
		, @InformacionExtra	= @InformacionExtra
GO
