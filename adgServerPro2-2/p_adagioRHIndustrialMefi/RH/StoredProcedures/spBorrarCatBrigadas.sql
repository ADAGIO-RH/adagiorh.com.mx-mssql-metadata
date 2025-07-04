USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Catálogo de Brigadas>
** Autor			: <Jose Rafael Roman Gil>
** Email			: <jose.roman@adagio.com.mx>
** FechaCreacion	: <08/06/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [RH].[spBorrarCatBrigadas]
(
	@IDBrigada int,
	@IDUsuario int
)
AS
BEGIN
		SELECT IDBrigada,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDBrigada)as ROWNUMBER
	FROM RH.tblCatBrigadas
	Where IDBrigada = @IDBrigada

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON =(SELECT IDBrigada
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatBrigadas] 
                            WHERE IDBrigada = @IDBrigada FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) 

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBrigadas]','[RH].[spBorrarCatBrigadas]','DELETE','',@OldJSON


	DELETE RH.tblCatBrigadas
	Where IDBrigada = @IDBrigada
END
GO
