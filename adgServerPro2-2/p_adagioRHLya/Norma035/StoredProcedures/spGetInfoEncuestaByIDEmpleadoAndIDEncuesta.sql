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



CREATE proc [Norma035].[spGetInfoEncuestaByIDEmpleadoAndIDEncuesta]
(@IDEmpleado INT,@IDEncuesta int)
as
BEGIN

	SELECT Estatus,IDRespuesta, IDPregunta,Respuesta 
	FROM Norma035.tblEncuestaEmpleado
	INNER JOIN  Norma035.tblRespuestasEmpleados ON Norma035.tblRespuestasEmpleados.IDEncuestaEmpleado= Norma035.tblEncuestaEmpleado.IDEncuestaEmpleado
	WHERE Norma035.tblEncuestaEmpleado.IDEmpleado=@IDEmpleado AND   Norma035.tblEncuestaEmpleado.IDEncuesta=@IDEncuesta;
	

	 	
end
GO
