USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para buscar los creditos Infonavit  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-09-06  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)	Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/  
CREATE PROCEDURE [RH].[spBuscarInfonavitEmpleados]  
(  
	@IDInfonavitEmpleado int = 0  
	,@IDUsuario int
)  
AS  
BEGIN  
  
 SELECT   
  IE.IDInfonavitEmpleado  
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
 FROM RH.tblInfonavitEmpleado IE with (nolock)   
	INNER JOIN RH.tblEmpleados E with (nolock)   
		on IE.IDEmpleado = E.IDEmpleado  
	INNER JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) 
		on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
	INNER JOIN RH.tblCatRegPatronal RegPatronal with (nolock)   
		on IE.IDRegPatronal = RegPatronal.IDRegPatronal  
	LEFT JOIN RH.tblCatInfonavitTipoMovimiento TipoMovimiento with (nolock)   
		on TipoMovimiento.IDTipoMovimiento = IE.IDTipoMovimiento  
	LEFT JOIN RH.tblCatInfonavitTipoDescuento TipoDescuento with (nolock)   
		on TipoDescuento.IDTipoDescuento = IE.IDTipoDescuento  
  where (IE.IDInfonavitEmpleado = @IDInfonavitEmpleado) or (@IDInfonavitEmpleado = 0)
END
GO
