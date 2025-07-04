USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA ACCIONES DE AUDITORIA
** Autor			: JOSE Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-11-09
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [Auditoria].[spBuscarAccionesAuditoria](
    @IDUsuario int
) as
	
     
    SELECT DISTINCT Accion FROM Auditoria.tblAuditoria WHERE isnull(accion,'') <>''
GO
