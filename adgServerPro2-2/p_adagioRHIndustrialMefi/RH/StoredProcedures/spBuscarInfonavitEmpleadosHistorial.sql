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
CREATE PROCEDURE [RH].[spBuscarInfonavitEmpleadosHistorial]
(
	@IDInfonavitEmpleado int = 0
	,@IDUsuario int
)
AS
BEGIN

	SELECT
		 IE.IDHistorialInfonavitEmpleado 
		,IE.IDInfonavitEmpleado
		,IE.IDEmpleado
		,E.ClaveEmpleado
		,substring(UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,49 ) as NombreCompleto
		,ISNULL(IE.IDRegPatronal,0) as IDRegPatronal
		,RegPatronal.RegistroPatronal
		,RegPatronal.RazonSocial
		,IE.NumeroCredito
		,ISNULL(IE.IDTipoMovimiento,0) as IDTipoMovimiento
		,TipoMovimiento.Descripcion as TipoMovimiento
		,IE.Fecha
		,ISNULL(IE.IDTipoDescuento,0) as IDTipoDescuento
		,TipoDescuento.Descripcion as TipoDescuento
		,IE.ValorDescuento
		,ISNULL(IE.AplicaDisminucion,0) as  AplicaDisminucion
		,IE.FolioAviso
		,isnull(IE.IDTipoAvisoInfonavit,0) AS IDTipoAviso
		,'['+TAI.codigo+'] - '+TAI.Clasificacion +' - '+ TAI.Descripcion as TipoAviso
		,ISNULL(IE.FechaEntraVigor,'9999-12-31') as FechaEntraVigor
		,ISNULL(IE.FechaFinVigor,'9999-12-31') as FechaFinVigor
 	FROM RH.tblHistorialInfonavitEmpleado IE	
		INNER JOIN RH.tblEmpleados E
			on IE.IDEmpleado = E.IDEmpleado
		INNER JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) 
			on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		INNER JOIN RH.tblCatRegPatronal RegPatronal
			on IE.IDRegPatronal = RegPatronal.IDRegPatronal
		LEFT JOIN RH.tblCatInfonavitTipoMovimiento TipoMovimiento
			on TipoMovimiento.IDTipoMovimiento = IE.IDTipoMovimiento
		LEFT JOIN RH.tblCatInfonavitTipoDescuento TipoDescuento
			on TipoDescuento.IDTipoDescuento = IE.IDTipoDescuento
		LEFT JOIN RH.tblcatTiposAvisosInfonavit TAI
			on TAI.IDTipoAvisoInfonavit = IE.IDTipoAvisoInfonavit

	where IE.IDInfonavitEmpleado = @IDInfonavitEmpleado
END
GO
