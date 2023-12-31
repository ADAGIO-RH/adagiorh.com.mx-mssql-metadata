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



CREATE proc [Norma035].[spGuardarEncuestaEmpleado]
(@IDEmpleado INT,@IDEncuesta INT,@Estatus int,@IDEncuestaEmpleado int)
as
BEGIN

	IF @IDEncuestaEmpleado=0 
		BEGIN
			INSERT into  Norma035.tblEncuestaEmpleado  
			(IDEmpleado,IDEncuesta,Fecha,Estatus)
			values ( @IDEmpleado,@IDEncuesta,GETDATE(),@Estatus);
			select SCOPE_IDENTITY() as "insertado";
		END
	ELSE 
		BEGIN
			UPDATE   Norma035.tblEncuestaEmpleado  
			SET Estatus=@Estatus where IDEncuestaEmpleado=@IDEncuestaEmpleado;

			select @IDEncuestaEmpleado as "insertado";

		END
	 	
end
GO
