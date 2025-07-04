USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION Asistencia.fnBuscarCatTiposPrivilegiosLectoresZK(	
	@IDIdioma varchar(10)
)
RETURNS TABLE 
AS
RETURN 
(
	select 
		[IDTipoPrivilegioLectorZK],
		JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre,
		Traduccion
	from Asistencia.[tblCatTiposPrivilegiosLectoresZK]
)
GO
