USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta y elimina metrica
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-28
** Paremetros		: @IDMetrica
**					: @IDAplicacion
**					: @Nombre
**					: @Descripcion
**					: @ConfiguracionFiltros
**					: @NombreProcedure
**					: @Background
**					: @Color
**					: @IDPeriodo
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

CREATE PROC [InfoDir].[spIDCatMetrica]
(
	@IDMetrica INT,
	@IDAplicacion NVARCHAR(100),
	@Nombre VARCHAR(100),
	@Descripcion VARCHAR(255),
	@ConfiguracionFiltros NVARCHAR(MAX),
	@NombreProcedure VARCHAR(255),
	@Background VARCHAR(50),
	@Color VARCHAR(50),
	@IDPeriodo INT,
	@IDUsuario INT,
	@FechaDe DATE,
	@FechaHasta DATE,
	@IsKpi BIT,
	@Objetivo DECIMAL(18,2)
)
AS
	BEGIN  
		
		DECLARE @OldJSON VARCHAR(MAX), @NewJSON VARCHAR(MAX);		
			
		IF(@IDMetrica = 0 OR @IDMetrica = NULL)
			BEGIN			

				INSERT INTO [InfoDir].[tblCatMetricas]([IDAplicacion], [Nombre], [Descripcion], [ConfiguracionFiltros], [NombreProcedure], [Background], [Color], [FechaDe], [FechaHasta], [IDPeriodo], [IsKpi], [Objetivo])
				VALUES(@IDAplicacion, @Nombre, @Descripcion, @ConfiguracionFiltros, @NombreProcedure, @Background, @Color, @FechaDe, @FechaHasta, @IDPeriodo, @IsKpi, @Objetivo)

				/* BITACORA AUDITORIA */

				SET @IDMetrica = @@identity  

				SELECT @NewJSON = A.JSON 
				FROM [InfoDir].[tblCatMetricas] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDMetrica = @IDMetrica

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[InfoDir].[tblCatMetricas]', '[InfoDir].[spIDCatMetrica]', 'INSERT', @NewJSON, ''
			
			END
		ELSE
			BEGIN

				SELECT @OldJSON = A.JSON
				FROM [InfoDir].[tblCatMetricas] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDMetrica = @IDMetrica

				EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[InfoDir].[tblCatMetricas]','[InfoDir].[spIDCatMetrica]','DELETE','', @OldJSON

				DELETE [InfoDir].[tblCatMetricas] WHERE IDMetrica = @IDMetrica

			END
			
	END
GO
