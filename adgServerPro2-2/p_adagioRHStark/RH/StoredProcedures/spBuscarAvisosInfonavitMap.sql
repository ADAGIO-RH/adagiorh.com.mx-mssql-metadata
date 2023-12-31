USE [p_adagioRHStark]
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
CREATE PROCEDURE [RH].[spBuscarAvisosInfonavitMap]  
(  
 @dtAvisosInfonavit [RH].[dtAvisosInfonavit] READONLY  
 ,@IDUsuario int
)  
AS  
BEGIN  
    
  SELECT   
   CAST(dt.[FechCreaAviso] as date) as FechaCreacion
   ,ISNULL(RP.IDRegPatronal,0) as IDRegPatronal 
   ,RP.RegistroPatronal as RegistroPatronal
   ,isnull(EM.IDEmpleado,0) as IDEmpleado
   ,isnull(EM.NombreCompleto,'') as NombreCompleto
   ,isnull(EM.RFC,'') as RFCEmpleado
   ,isnull(dt.NSS,'') as NSS
   ,ISNULL(hie.IDHistorialAvisosInfonavitEmpleado,0) as IDHistorialAvisosInfonavitEmpleado
   ,isnull(dt.FolioAviso,'') as FolioAviso
   ,ISNULL(InfoEmp.IDInfonavitEmpleado,0) as IDInfonavitEmpleado
   ,isnull(dt.NumCredito,'') as NumeroCredito 
   , CONVERT(DATE, STUFF(STUFF(STUFF(dt.FechaUltimoAviso,13,0,':'),11,0,':'),9,0,' ')) as FechaUltimoAviso	 
   , CASE WHEN isnull(TAI.IDTipoAvisoInfonavit,0) not in (4,8) THEN CAST(dt.[FechCreaAviso] as date) 
				 else
					DATEADD(day,1,app.fngetFinBimestreByFecha(CAST(dt.[FechCreaAviso] as date)))
				 END as FechaEntradaVigor
   , isnull(TAI.IDTipoAvisoInfonavit,0) as IDTipoAvisoInfonavit
   ,'['+TAI.codigo+'] - '+TAI.Clasificacion +' - '+ TAI.Descripcion as TipoAviso
   , ISNULL(TD.IDTipoDescuento,0) as IDTipoDescuento
   ,'['+TD.codigo+'] - '+ TD.Descripcion as TipoDescuento
   , CASE WHEN TD.Codigo in( '1','2') THEN dt.MonDescuento
		  ELSE dt.FacDescuento END as Factor
  FROM @dtAvisosInfonavit dt 
	Left JOIN RH.tblEmpleadosMaster em on dt.NSS = em.IMSS	
		OR dt.RFCTrabajador = em.RFC
	Inner join RH.tblEmpresa e
		on dt.RFCEmpresa = E.RFC
	Inner join RH.tblCatRegPatronal RP
		on RP.RegistroPatronal = dt.NRP
	Inner join RH.tblcatTiposAvisosInfonavit TAI
		on TAI.Codigo = dt.TipoAviso
	left join RH.tblInfonavitEmpleado InfoEmp
		on InfoEmp.NumeroCredito = dt.NumCredito
	left join RH.tblCatInfonavitTipoDescuento TD
		on TD.Codigo = dt.TipoDescuento
	left join RH.[tblHistorialAvisosInfonavitEmpleado] hie
		on hie.IDInfonavitEmpleado = InfoEmp.IDInfonavitEmpleado
		and HIE.FolioAviso = dt.FolioAviso
  
   
END
GO
