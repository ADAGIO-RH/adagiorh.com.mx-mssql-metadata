USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS TIPOS DE LECTORES
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)		Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-05-13				Aneudy Abreu		Se agregó el parámetro @SoloActivos
											Se agregó el campo Configuracion
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBuscarTiposLectores](
	@IDTipoLector Nvarchar(100) = NULL,
	@SoloActivos bit = 0,
	@IDUsuario int
)
AS
BEGIN
	SELECT 
		IDTipoLector
		,TipoLector
		,isnull(Activo,0 ) as Activo
		,Configuracion
		,ROW_NUMBER()OVER(ORDER BY IDTipoLector asc) ROWNUMBER 
	from Asistencia.tblCatTiposLectores 
	WHERE ((IDTipoLector = @IDTipoLector) OR (isnull(@IDTipoLector,'') = ''))
		and (isnull(Activo, 0) = case when isnull(@SoloActivos, 0) = 1 then isnull(@SoloActivos, 0) else isnull(Activo, 0) end)
		
END
GO
