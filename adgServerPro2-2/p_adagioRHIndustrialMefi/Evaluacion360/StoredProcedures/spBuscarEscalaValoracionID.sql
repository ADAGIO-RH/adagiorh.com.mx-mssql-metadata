USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca el grupo de nombres y valores que le pertenecen a una escala
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 16-02-2023
** Paremetros		: @IDEscalaValoracion	Identificador de la escala
					: @IDUsuario			Identificador del usuario

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   PROC [Evaluacion360].[spBuscarEscalaValoracionID](
	@IDEscalaValoracion INT = 1,
	@IDUsuario INT = 0
) AS

	SELECT IDEscalaValoracion,
		   Nombre,
		   Valor
	FROM [Evaluacion360].[tblDetalleEscalaValoracion]
	WHERE IDEscalaValoracion = @IDEscalaValoracion
GO
