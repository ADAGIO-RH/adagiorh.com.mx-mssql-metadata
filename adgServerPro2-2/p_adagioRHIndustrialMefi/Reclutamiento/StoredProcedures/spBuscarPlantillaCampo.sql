USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-22
-- Description:	sp para buscar los campos que serán dinámicos en las plantillas
-- [Reclutamiento].[spBuscarPlantillaCampo]@Tabla = 'Candidato'
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarPlantillaCampo]
(
	@Tabla varchar(50) = '',
	@Categorias bit = 0
)
AS
BEGIN

	declare @CamposDeBusqueda table(
			IDCamposDeBusqueda int,
			Tabla varchar(255),
			Campo varchar(255),
			Descripcion varchar(255)
		)
	
	INSERT INTO @CamposDeBusqueda
	SELECT  
			IDCamposDeBusqueda, 
			Tabla, 
			Campo, 
			Descripcion
	FROM            
			Reclutamiento.tblCamposDeBusqueda

	IF OBJECT_ID('tempdb..#tmpConfPlaza') IS NOT NULL
    DROP TABLE #tmpConfPlaza
	CREATE TABLE #tmpConfPlaza
					(
					   IDTipoConfiguracionPlaza varchar(max),
					   TipoConfiguracionPlaza varchar(max),
					   Configuracion varchar(max),
					   valor varchar(max),
					   descripcion varchar(max),
					   Orden int
					)

	INSERT INTO #tmpConfPlaza
	EXEC [RH].[spBuscarConfiguracionesPlazaByID]@IDPlaza=0,@IDUsuario=1,@WithDescripcion=0

	IF OBJECT_ID('tempdb..#tmpConfPlazaResult') IS NOT NULL
    DROP TABLE #tmpConfPlazaResult
	CREATE TABLE #tmpConfPlazaResult
					(
					   IDCamposDeBusqueda varchar(max),
					   Tabla varchar(max),
					   Campo varchar(max),
					   Descripcion varchar(max)
					)

	INSERT INTO #tmpConfPlazaResult
	SELECT ROW_NUMBER() OVER (ORDER BY IDCamposDeBusqueda) as IDCamposDeBusqueda, Tabla, Campo, Descripcion
			FROM (
				SELECT 
					IDCamposDeBusqueda, 
					Tabla, 
					Campo, 
					Descripcion 
				FROM 
					@CamposDeBusqueda b
			UNION ALL
				select 
					1 as IDCamposDeBusqueda, 
					'Plaza', 
					IDTipoConfiguracionPlaza, 
					TipoConfiguracionPlaza 
				FROM 
					#tmpConfPlaza) c

	IF(@Categorias = 1)
	BEGIN
		SELECT Tabla FROM #tmpConfPlazaResult GROUP BY Tabla ORDER BY 1
	END
	ELSE
	BEGIN 
		SELECT 
			IDCamposDeBusqueda,
			Tabla,
			Campo,
			Descripcion 
		FROM 
			#tmpConfPlazaResult 
		WHERE 
			(Tabla = @Tabla OR ISNULL(@Tabla,'') = '') 
	END

END
GO
