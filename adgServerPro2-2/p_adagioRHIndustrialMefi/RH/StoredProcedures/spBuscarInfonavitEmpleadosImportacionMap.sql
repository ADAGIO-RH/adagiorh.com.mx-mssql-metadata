USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para Mapear la importacion de creditos infornavit masivos Map
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
CREATE PROCEDURE [RH].[spBuscarInfonavitEmpleadosImportacionMap]  
(  
 @dtCreditosInfonavit [RH].[dtInfonavitEmpleadosMap] READONLY  
 ,@IDUsuario int
)  
AS  
BEGIN  
    
  SELECT   
   dt.[IDInfonavitEmpleado]  
   ,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])  
   else 0  
   end as IDEmpleado  
  ,dt.[ClaveEmpleado]  
  ,dt.[NumeroCredito]  
  ,isnull(dt.[Fecha],'9999-12-31') as Fecha

  ,CASE WHEN EXISTS (SELECT TOP 1 IDTipoDescuento FROM RH.tblCatInfonavitTipoDescuento where Descripcion = dt.[TipoDescuento]) THEN (SELECT TOP 1 IDTipoDescuento FROM RH.tblCatInfonavitTipoDescuento where Descripcion = dt.[TipoDescuento])  
   ELSE 0  
   END as IDTipoDescuento
  ,dt.[TipoDescuento]
   ,CASE WHEN EXISTS (SELECT TOP 1 IDRegPatronal FROM RH.tblCatRegPatronal where RegistroPatronal = dt.[RegPatronal]) THEN (SELECT TOP 1 IDRegPatronal FROM RH.tblCatRegPatronal where RegistroPatronal = dt.[RegPatronal])  
   ELSE 0  
   END as IDRegPatronal
  ,dt.[RegPatronal] as [RegistroPatronal]
,dt.[RegPatronal]  
  ,dt.[ValorDescuento]  
  ,dt.[AplicaDisminucion]
  ,dt.TipoMovimiento 
  ,citm.IDTipoMovimiento
  FROM @dtCreditosInfonavit dt     
	INNER JOIN RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
	INNER JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario 
    inner join RH.tblCatInfonavitTipoMovimiento citm on citm.Descripcion=dt.TipoMovimiento
  where dt.ClaveEmpleado <> ''   
   
END
GO
