USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para buscar los creditos Infonavit Historial
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2023-06-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [Reportes].[spReporteBasicoGenerarExcelInfonavitEmpleadosHistorial]
(
	@IDInfonavitEmpleado int = 0
    ,@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
)
AS
BEGIN

	SELECT
		 IE.Fecha
		,IE.NumeroCredito as [Numero Credito]		 
		
		,TipoDescuento.Descripcion as [Tipo Descuento]
		,TipoMovimiento.Descripcion as [Tipo Movimiento]		
		,IE.ValorDescuento as [Valor Descuento]
		,CASE WHEN ISNULL(IE.AplicaDisminucion,0)= 1 THEN 'SI' ELSE 'NO' END as [Disminución]		
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
