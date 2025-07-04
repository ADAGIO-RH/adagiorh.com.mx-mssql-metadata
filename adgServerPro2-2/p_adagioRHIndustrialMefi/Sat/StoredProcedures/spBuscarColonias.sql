USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar las colonias de un código postal
** Autor			: Jose Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-06-20		Aneudy Abreu		Quité de la 'or @IDCodigoPostal = 0'
***************************************************************************************************/
CREATE PROCEDURE [Sat].[spBuscarColonias]
(
	@Colonia Varchar(50) = null,
	@IDCodigoPostal int = null
)
AS
BEGIN
	select top 100
		IDColonia
		,UPPER(Codigo) AS Codigo
		,IDCodigoPostal
		,UPPER(NombreAsentamiento) AS NombreAsentamiento
	From [Sat].[tblCatColonias]
	where (IDCodigoPostal = @IDCodigoPostal) OR (isnull(@IDCodigoPostal,0) = 0)
	--and ((NombreAsentamiento like @Colonia +'%') 
	--	OR (Codigo like @Colonia+'%')  
	--	OR (@Colonia is null)) 	
END
GO
