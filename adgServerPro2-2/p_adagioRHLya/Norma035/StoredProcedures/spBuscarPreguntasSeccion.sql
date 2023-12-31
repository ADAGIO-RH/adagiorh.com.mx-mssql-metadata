USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtener Encuestas
** Autor			: Denzel Ovando
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2020-06-17
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [Norma035].[spBuscarPreguntasSeccion]
(@IDSeccion INT
,@IDUsuario INT)
as


SELECT 
	  [IDPregunta]
      ,[IDSeccion]
      ,[Pregunta]
      ,[RespuestaMaxima]
      ,[Puntos]
      ,[Estatus]
      ,[UltimaActualizacion]
FROM [Norma035].[tblCatPreguntas] 
WHERE IDSeccion  = @IDSeccion
AND Estatus = 1
GO
