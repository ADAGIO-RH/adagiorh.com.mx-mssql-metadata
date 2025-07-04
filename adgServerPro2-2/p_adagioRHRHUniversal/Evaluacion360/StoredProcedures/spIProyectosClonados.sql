USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta los datos del proyectos clonado.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-01-24
** Parametros		: @IDProyectoOriginal		Identificador del proyecto original
**					: @IDProyectoClonado		Identificador del proyecto clonado
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #1346

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spIProyectosClonados](
	@IDProyectoOriginal		INT = 0
	, @IDProyectoClonado	INT = 0
	, @IDUsuario			INT = 0
)
AS
	BEGIN

		DECLARE @FechaCreacionClon DATE = GETDATE();
		
		INSERT INTO [Evaluacion360].[tblProyectosClonados]
		SELECT
				-- PROYECTO ORIGINAL
				P_ORI.IDProyecto AS IDProyectoOriginal
				, P_ORI.Nombre AS NombreProyectoOriginal				
				, P_ORI.FechaInicio AS FechaInicioProyectoOriginal
				, P_ORI.FechaFin AS FechaFinProyectoOriginal

				-- PROYECTO CLON				
				, P_CLON.IDProyecto AS IDProyectoClon
				, P_CLON.Nombre AS NombreProyectoClon
				, @FechaCreacionClon AS FechaCreacionClon
				-- ENCARGADOS PROYECTOS
				, CASE WHEN EPR.IDCatalogoGeneral = 3 THEN COALESCE(EPR.Nombre, '') ELSE '' END NombreContactoProyectoClon
				, CASE WHEN EPR.IDCatalogoGeneral = 3 THEN COALESCE(EPR.Email, '') ELSE '' END EmailContactoProyectoClon
				-- EDITORES
				, E.IDEditor
				, E.Editor AS NombreEditor
				-- EMAILS
				, Email = ISNULL(E.EmailEditor, (SELECT CE.[Value] AS Email FROM [RH].[tblContactoEmpleado] CE WHERE CE.IDEmpleado = E.IDEmpleado))
				, EmailValid = [Utilerias].[fsValidarEmail](ISNULL(E.EmailEditor, (SELECT CE.[Value] AS Email FROM [RH].[tblContactoEmpleado] CE WHERE CE.IDEmpleado = E.IDEmpleado)))

		FROM [Evaluacion360].[tblCatProyectos] P_CLON
			LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] EPR WITH (NOLOCK) ON P_CLON.IDProyecto = EPR.IDProyecto
			LEFT JOIN [Evaluacion360].[tblCatProyectos] P_ORI ON P_ORI.IDProyecto = @IDProyectoOriginal
			LEFT JOIN (
						SELECT AP.IDProyecto
								, U.IDUsuario AS IDEditor
								, (U.Nombre + ' ' + U.Apellido) AS Editor
								, U.Email AS EmailEditor
								, U.IDEmpleado AS IDEmpleado
						FROM [Evaluacion360].[tblAdministradoresProyecto] AP
							JOIN [Seguridad].[tblUsuarios] U ON U.IDUsuario = AP.IDUsuario
					  ) E ON P_CLON.IDProyecto = E.IDProyecto
		WHERE P_CLON.IDProyecto = @IDProyectoClonado


	END
GO
