USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para buscar los creditos Infonavit Historial
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-06
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarAvisosInfonavitEmpleadosHistorial]
(
	 @IDEmpleado int = 0
	,@IDHistorialAvisosInfonavitEmpleado int  = 0
	,@IDUsuario int
)
AS
BEGIN
  SELECT   
   ISNULL(hie.IDHistorialAvisosInfonavitEmpleado,0) as IDHistorialAvisosInfonavitEmpleado
   ,isnull(EM.IDEmpleado,0) as IDEmpleado
   ,isnull(EM.ClaveEmpleado,'') as ClaveEmpleado
   ,isnull(EM.NombreCompleto,'') as NombreCompleto
   ,isnull(EM.RFC,'') as RFCEmpleado
   ,isnull(em.IMSS,'') as NSS
   ,ISNULL(RP.IDRegPatronal,0) as IDRegPatronal 
   ,isnull(RP.RegistroPatronal,'') as RegistroPatronal
   ,ISNULL(e.IdEmpresa,0) as IDEmpresa 
   ,ISNULL(e.RFC,'') as RFCEmpresa
   ,e.NombreComercial as Empresa
   ,isnull(HIE.FolioAviso,'') as FolioAviso
   ,isnull(HIE.NumeroCredito,'') as NumeroCredito 
   ,CAST(HIE.FechaOtorgamiento as date) as FechaOtorgamiento
   , (HIE.FechCreaAviso)  as FechaCreacion
   ,isnull(HIE.MonDescuento,0) as MontoDescuento
   ,isnull(HIE.FacDescuento,0) as FacDescuento
   ,ISNULL(HIE.SelloDigital,'') as SelloDigital
   ,ISNULL(HIE.CadenaOriginal,'') as CadenaOriginal
   , ISNULL(TD.IDTipoDescuento,0) as IDTipoDescuento
   ,'['+TD.codigo+'] - '+ TD.Descripcion as TipoDescuento
   , isnull(TAI.IDTipoAvisoInfonavit,0) as IDTipoAvisoInfonavit
   ,'['+TAI.codigo+'] - '+TAI.Clasificacion +' - '+ TAI.Descripcion as TipoAviso
   , HIE.FechaUltimoAviso as FechaUltimoAviso	 
   ,ROW_NUMBER()OVER(ORDER BY HIE.IDHistorialAvisosInfonavitEmpleado) as ROWNUMBER
  FROM RH.[tblHistorialAvisosInfonavitEmpleado] hie  WITH(NOLOCK)
	inner JOIN RH.tblEmpleadosMaster em WITH(NOLOCK)
		on hie.IDEmpleado = em.IDEmpleado	
	inner join RH.tblEmpresa e WITH(NOLOCK)
		on hie.IDEmpresa = E.IDEmpresa
	inner join RH.tblCatRegPatronal RP WITH(NOLOCK)
		on RP.IDRegPatronal = hie.IDRegPatronal
	inner join RH.tblcatTiposAvisosInfonavit TAI WITH(NOLOCK)
		on TAI.IDTipoAvisoInfonavit = hie.IDTipoAvisoInfonavit
	inner join RH.tblCatInfonavitTipoDescuento TD  WITH(NOLOCK)
		on TD.IDTipoDescuento = hie.IDTipoDescuento
	WHERE HIE.IDEmpleado = @IDEmpleado
	and (HIE.IDHistorialAvisosInfonavitEmpleado = @IDHistorialAvisosInfonavitEmpleado OR isnull(@IDHistorialAvisosInfonavitEmpleado,0) = 0 )
	ORDER BY HIE.NumeroCredito ASC,HIE.FechCreaAviso DESC
END
GO
