USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualiza la escala de satisfaccion en clima laboral
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-09
** Paremetros		: @JsonSatisfaccion		- Datos a actualizar.
**					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Evaluacion360].[spUEscalaSatisfaccionGeneral](
	@JsonSatisfaccion NVARCHAR(MAX)
	, @IDUsuario	  INT
)
AS

	DECLARE @IDProyecto INT
			, @OldJSON VARCHAR(MAX)
			, @NewJSON VARCHAR(MAX)
			;

	-- CREAMOS TABLAS TEMPORALES
	DECLARE @TblEscalaSatisfaccion TABLE(
		[IDEscalaSatisfaccion] INT
		, [Nombre]			   VARCHAR(100)
		, [Descripcion]		   VARCHAR(100)
		, [Min]				   FLOAT
		, [Max]				   FLOAT
		, [Color]			   VARCHAR(20)
		, [IndiceSatisfaccion] INT
		, [IDProyecto]		   INT
	)

	-- CONVERTIMOS @JsonSatisfaccion A TABLA
	INSERT @TblEscalaSatisfaccion(IDEscalaSatisfaccion, Nombre, Descripcion, [Min], [Max], Color, IndiceSatisfaccion, IDProyecto)
	SELECT *
	FROM OPENJSON(JSON_QUERY(@JsonSatisfaccion,  '$'))
		WITH (
			IDEscalaSatisfaccion INT '$.IDEscalaSatisfaccion'
			, Nombre			 VARCHAR(100) '$.Nombre'
			, Descripcion		 VARCHAR(100) '$.Descripcion'
			, [Min]				 FLOAT		  '$.Min'
			, [Max]				 FLOAT		  '$.Max'
			, Color				 VARCHAR(20)  '$.Color'
			, IndiceSatisfaccion INT		  '$.IndiceSatisfaccion'
			, IDProyecto		 INT		  '$.IDProyecto'
		);
	

	BEGIN TRY
					
		BEGIN TRAN			
			
			SELECT TOP 1 @IDProyecto = IDProyecto FROM @TblEscalaSatisfaccion			

			SELECT @OldJSON = (SELECT IDEscalaSatisfaccion
									  , Nombre
									  , Descripcion
									  , CAST([Min] AS VARCHAR(20)) AS [Min]
									  , CAST([Max] AS VARCHAR(20)) AS [Max]
									  , Color
									  , IndiceSatisfaccion
									  , IDProyecto
							   FROM [Evaluacion360].[tblEscalaSatisfaccionGeneral] WHERE IDProyecto = @IDProyecto FOR JSON AUTO);
				
			-- ACTUALIZAMOS DATOS
			UPDATE ESG
				SET ESG.[Min] = TES.[Min] / 100
					, ESG.[Max] = TES.[Max] / 100
					, ESG.Color = TES.Color
			FROM [Evaluacion360].[tblEscalaSatisfaccionGeneral] ESG
				JOIN @TblEscalaSatisfaccion TES ON ESG.IDEscalaSatisfaccion = TES.IDEscalaSatisfaccion;

		IF @@ROWCOUNT > 0
			COMMIT TRAN
		ELSE
			ROLLBACK TRAN 

		
		SELECT @NewJSON = (SELECT IDEscalaSatisfaccion
									  , Nombre
									  , Descripcion
									  , CAST([Min] AS VARCHAR(20)) AS [Min]
									  , CAST([Max] AS VARCHAR(20)) AS [Max]
									  , Color
									  , IndiceSatisfaccion
									  , IDProyecto
							   FROM [Evaluacion360].[tblEscalaSatisfaccionGeneral] WHERE IDProyecto = @IDProyecto FOR JSON AUTO);		
		

		EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Evaluacion360].[tblEscalaSatisfaccionGeneral]', '[Evaluacion360].[spUEscalaSatisfaccion]', 'UPDATE', @NewJSON, @OldJSON					
			

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT ERROR_MESSAGE() AS ErrorMessage;
		END CATCH
GO
