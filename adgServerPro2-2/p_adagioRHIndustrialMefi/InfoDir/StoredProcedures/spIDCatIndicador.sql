USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta y elimina indicador
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-05-09
** Paremetros		: @IDIndicador
**					: @IDAplicacion
**					: @Nombre
**					: @Descripcion
**					: @ConfiguracionFiltros
**					: @NombreProcedure
**					: @IDPeriodo
**					: @IDGrafica
**					: @IDUsuario
**					: @FechaDe
**					: @FechaHasta
** IDAzure			: 822

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spIDCatIndicador]
(
	@IDIndicador INT,
	@IDAplicacion NVARCHAR(100),
	@Nombre VARCHAR(100),
	@Descripcion VARCHAR(255),
	@ConfiguracionFiltros NVARCHAR(MAX),
	@ConfiguracionGroupBy NVARCHAR(MAX),
	@NombreProcedure VARCHAR(255),
	@IDPeriodo INT,
	@IDGrafica INT,
	@IDUsuario INT,
	@FechaDe DATE,
	@FechaHasta DATE
)
AS
	BEGIN  
		
		DECLARE @OldJSON VARCHAR(MAX), @NewJSON VARCHAR(MAX);
			
		IF(@IDIndicador = 0 OR @IDIndicador = NULL)
			BEGIN			

				INSERT INTO [InfoDir].[tblCatIndicadores]([IDAplicacion], [Nombre], [Descripcion], [ConfiguracionFiltros], [ConfiguracionGroupBy], [NombreProcedure], [FechaDe], [FechaHasta], [IDPeriodo], [IDGrafica])
				VALUES(@IDAplicacion, @Nombre, @Descripcion, @ConfiguracionFiltros, @ConfiguracionGroupBy, @NombreProcedure, @FechaDe, @FechaHasta, @IDPeriodo, @IDGrafica)

				/* BITACORA AUDITORIA */

				SET @IDIndicador = @@identity  

				SELECT @NewJSON = A.JSON 
				FROM [InfoDir].[tblCatIndicadores] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDIndicador = @IDIndicador

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[InfoDir].[tblCatIndicadores]', '[InfoDir].[spIDCatIndicador]', 'INSERT', @NewJSON, ''
			
			END
		ELSE
			BEGIN

				SELECT @OldJSON = A.JSON
				FROM [InfoDir].[tblCatIndicadores] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDIndicador = @IDIndicador

				EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[InfoDir].[tblCatIndicadores]','[InfoDir].[spIDCatIndicador]','DELETE','', @OldJSON

				DELETE [InfoDir].[tblCatIndicadores] WHERE IDIndicador = @IDIndicador

			END
			
	END
GO
