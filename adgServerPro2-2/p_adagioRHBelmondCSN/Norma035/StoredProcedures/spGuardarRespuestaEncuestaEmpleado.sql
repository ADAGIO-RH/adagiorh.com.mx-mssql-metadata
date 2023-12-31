USE [p_adagioRHBelmondCSN]
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



CREATE proc [Norma035].[spGuardarRespuestaEncuestaEmpleado]
(@IDEncuestaEmpleado INT,@IDPregunta INT,@Respuesta int)
as
BEGIN

	DECLARE @existe int;
	IF EXISTS (SELECT * FROM  Norma035.tblRespuestasEmpleados WHERE IDEncuestaEmpleado = @IDEncuestaEmpleado and IDPregunta = @IDPregunta )
		BEGIN
			UPDATE   Norma035.tblRespuestasEmpleados  
			SET Respuesta=@Respuesta ,UltimaActualizacion=GETDATE() 
			where  IDEncuestaEmpleado = @IDEncuestaEmpleado and IDPregunta = @IDPregunta ;
			
		END
	ELSE 
		BEGIN
			INSERT Norma035.tblRespuestasEmpleados 
			(IDEncuestaEmpleado,IDPregunta,Respuesta,UltimaActualizacion)
			VALUES(@IDEncuestaEmpleado,@IDPregunta,@Respuesta,GETDATE());
			
		END

	

	 	
end
GO
