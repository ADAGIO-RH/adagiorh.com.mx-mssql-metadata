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
CREATE proc [Norma035].[spBuscarMensajesDenunciaPorIDDenuncia]
(@IDDenuncia INT, @IDUsuario INT)
as
BEGIN

	
		SELECT [IDMensajeDenuncia]
			  ,[IDDenuncia]
			  ,MD.IDEmpleado as IDEmpleadoEnvia
			  ,@IDUsuario as IDEmpleadoRecibe
			  ,[FechaHora]
			  ,[Texto]
			  ,Concat(E.Nombre ,' ', E.SegundoNombre ,' ', E.Paterno,' ', E.Materno) as NombreEmpelado
			  ,CASE
				WHEN (@IDUsuario = MD.IDEmpleado) THEN 'TRUE'
				ELSE 'FALSE'
			  END as Remitente
		  FROM [Norma035].[tblMensajesDenuncia] MD 
		  Join RH.tblEmpleados E on MD.IDEmpleado = E.IDEmpleado 
		  where MD.IDDenuncia = @IDDenuncia


	end
GO
