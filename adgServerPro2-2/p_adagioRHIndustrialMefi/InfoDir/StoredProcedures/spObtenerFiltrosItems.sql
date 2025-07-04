USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene los filtros por item solicitado
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-12
** Paremetros		: @IDTipoItem
** IDAzure			: 814

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spObtenerFiltrosItems]
(
	@IDTipoItem INT
)
AS
	BEGIN
		
		DECLARE @Activo BIT = 1;

		SELECT F.IDFiltroItem,
			   F.IsChecked,
			   F.LabelText,
			   F.NombreParametro,
			   F.NombreElemento,
			   F.MsjError,
			   F.IsRequired,			   		   
			   F.IDTipoComponente,
			   F.DisplayValue,
			   F.DisplayMember,
			   F.DisplayMemberColor
		FROM [InfoDir].[tblCatFiltrosItems] F
		WHERE F.IDTipoItem = @IDTipoItem AND
			  F.IsActive = @Activo

	END
GO
