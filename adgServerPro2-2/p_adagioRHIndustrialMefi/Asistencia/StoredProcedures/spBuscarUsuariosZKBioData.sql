USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS USUARIOS ZK
** Autor			: DENZEL OVANDO
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2021-11-26
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBuscarUsuariosZKBioData]
(
	 @IDEmpleado int = 0
)
AS
BEGIN

	SELECT [IDUsuariosZKBiodata]
		  ,[IDEmpleado]
		  ,[EnrollNumber]
		  ,[TemplateNumber]
		  ,[Index]
		  ,[Valid]
		  ,[Duress]
		  ,[Type]
		  ,[MajorVer]
		  ,[MinorVer]
		  ,[Format]
		  ,[Template]
	  FROM [Asistencia].[tblUsuariosZKBiodata]
	   WHERE [IDEmpleado] = @IDEmpleado or ISNULL(@IDEmpleado,0) = 0

END
GO
