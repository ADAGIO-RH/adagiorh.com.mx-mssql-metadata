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
CREATE PROCEDURE [RH].[spBuscarAvisosInfonavitMap]  
(  
 @dtAvisosInfonavit [RH].[dtAvisosInfonavit] READONLY  
 ,@IDUsuario int
)  
AS  
BEGIN  
--declare @dtAvisosInfonavit [RH].[dtAvisosInfonavit]
    
  SELECT   
   ISNULL(hie.IDHistorialAvisosInfonavitEmpleado,0) as IDHistorialAvisosInfonavitEmpleado
   ,isnull(EM.IDEmpleado,0) as IDEmpleado
   ,isnull(EM.ClaveEmpleado,'') as ClaveEmpleado
   ,isnull(EM.NombreCompleto,'') as NombreCompleto
   ,isnull(EM.RFC,dt.RFCTrabajador) as RFCEmpleado
   ,isnull(dt.NSS,'') as NSS
   ,ISNULL(RP.IDRegPatronal,0) as IDRegPatronal 
   ,isnull(RP.RegistroPatronal,dt.NRP) as RegistroPatronal
   ,ISNULL(e.IdEmpresa,0) as IDEmpresa 
   ,ISNULL(dt.RFCEmpresa,'') as RFCEmpresa
   ,e.NombreComercial as Empresa
   ,isnull(dt.FolioAviso,'') as FolioAviso
   ,isnull(dt.NumCredito,'') as NumeroCredito 
   , CASE WHEN dt.[FechOtorgamiento] = '00000000' THEN convert(date,substring(dt.FechCreaAviso,0,11),103)
		ELSE FORMAT(CONVERT(DATE, dt.[FechOtorgamiento] ), 'yyyy-MM-dd') 
		END as FechaOtorgamiento
   ---,CONVERT(DATE, STUFF(STUFF(dt.FechCreaAviso,5,0,'-'),8,0,'-')) as FechaCreacion
   ,convert(date,substring(dt.FechCreaAviso,0,11),103) as FechaCreacion
   ,isnull(dt.MonDescuento,0) as MontoDescuento
   ,isnull(dt.FacDescuento,0) as FacDescuento
   ,ISNULL(dt.SelloDigital,'') as SelloDigital
   ,ISNULL(dt.CadenaOriginal,'') as CadenaOriginal
   , ISNULL(TD.IDTipoDescuento,0) as IDTipoDescuento
   ,'['+TD.codigo+'] - '+ TD.Descripcion as TipoDescuento
   , isnull(TAI.IDTipoAvisoInfonavit,0) as IDTipoAvisoInfonavit
   ,'['+TAI.codigo+'] - '+TAI.Clasificacion +' - '+ TAI.Descripcion as TipoAviso
   , CONVERT(DATE, STUFF(STUFF(STUFF(dt.FechaUltimoAviso,13,0,':'),11,0,':'),9,0,' ')) as FechaUltimoAviso	 
   ,ISNULL(dt.TipoCredito,'') as TipoCredito
   ,TipoRegistro = CASE WHEN hie.IDHistorialAvisosInfonavitEmpleado is not null then 1 -- EXISTENTE
						WHEN hie.IDHistorialAvisosInfonavitEmpleado is null 
									and e.IDEmpresa is not null 
									and em.IDEmpleado is not null
									and RP.IDRegPatronal is not null THEN 2 -- NO EXISTENTE PERO TRABAJABLE
						ELSE 3 -- NO TRABAJABLE
						END
   --, CASE WHEN isnull(TAI.IDTipoAvisoInfonavit,0) not in (4,8) THEN CAST(dt.[FechCreaAviso] as date) 
			--	 else
			--		DATEADD(day,1,app.fngetFinBimestreByFecha(CAST(dt.[FechCreaAviso] as date)))
			--	 END as FechaEntradaVigor
  
  FROM @dtAvisosInfonavit dt 
	Left JOIN RH.tblEmpleadosMaster em on dt.NSS = em.IMSS	
		--and dt.RFCTrabajador = em.RFC
	left join RH.tblEmpresa e
		on dt.RFCEmpresa = E.RFC
	left join RH.tblCatRegPatronal RP
		on RP.RegistroPatronal = dt.NRP
	left join RH.tblcatTiposAvisosInfonavit TAI
		on TAI.Codigo = dt.TipoAviso
	left join RH.tblCatInfonavitTipoDescuento TD
		on TD.Codigo = dt.TipoDescuento
	left join RH.[tblHistorialAvisosInfonavitEmpleado] hie
		on HIE.FolioAviso = dt.FolioAviso
	--where --CAST(dt.[FechOtorgamiento] as date) > '1900-01-01'	
 --  FORMAT(CONVERT(DATE, dt.[FechOtorgamiento] ), 'yyyy-MM-dd') > '1900-01-01'	
END
GO
