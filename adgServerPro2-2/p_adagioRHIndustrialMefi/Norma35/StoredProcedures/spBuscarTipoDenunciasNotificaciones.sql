USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBuscarTipoDenunciasNotificaciones]
(
	  @IDTipoDenuncia INT = NULL
	  ,@IDUsuario int
)
AS
BEGIN

	SELECT 
	  [IDTipoDenunciasNotificacion]
      ,[IDTipoDenuncia]
      ,tde.[IDUsuario]
      ,[EmailAsignado]
	  ,u.Cuenta
	  ,concat(u.Nombre,' ',u.Apellido) as NombreCompleto
  FROM [Norma35].[tblTipoDenunciasNotificaciones] tde
  JOIN Seguridad.tblUsuarios u on tde.IDUsuario = u.IDUsuario
  WHERE (ISNULL(@IDTipoDenuncia,0) = 0 OR IDTipoDenuncia = @IDTipoDenuncia) 

END
GO
