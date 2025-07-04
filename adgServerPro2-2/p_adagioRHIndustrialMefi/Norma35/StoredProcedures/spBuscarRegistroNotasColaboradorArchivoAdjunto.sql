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
CREATE PROCEDURE [Norma35].[spBuscarRegistroNotasColaboradorArchivoAdjunto]
	-- Add the parameters for the stored procedure here
	@IDUsuario int 
    ,@IDRegistroNotasColaborador int
    
AS
BEGIN
	
    select c.IDRegistroNotasColaboradorArchivoAdjunto,c.IDRegistroNotasColaborador,c.Name,c.Notas,c.ContentType,c.[Data],c.IDUsuario, s.Nombre [NombreUsuario]
    
    from Norma35.tblRegistroNotasColaboradorArchivoAdjunto as c
    inner join Seguridad.tblUsuarios s on s.IDUsuario=c.IDUsuario
    where c.IDRegistroNotasColaborador=@IDRegistroNotasColaborador 

END
GO
