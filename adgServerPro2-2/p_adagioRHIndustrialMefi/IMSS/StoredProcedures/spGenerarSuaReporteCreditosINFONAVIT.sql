USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarSuaReporteCreditosINFONAVIT]  
(  
@FechaIni date = '1900-01-01',                
 @Fechafin date = '9999-12-31',                
 @AfectaIDSE bit = 0,  
 @FechaIDSE date = '9999-12-31',     
  @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
  @IDUsuario int  
)  
AS  
BEGIN  
   
 declare @IDRegPatronal int
	 , @dtEmpleados RH.dtEmpleados;

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')

   insert into @dtEmpleados      
   exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario    
  
  
 select  [App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS  
     -- + [App].[fnAddString](2,ISNULL(' ',''),'',2)  
   + [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL  
    
   + [App].[fnAddString](10,ISNULL(IE.NumeroCredito,''),'',2) -- NUMERO DE CRÉDITO INFONAVIT(*)  
   + [App].[fnAddString](2,ISNULL(TM.Codigo,''),'',2) -- Tipo de Movimiento  
   + [App].[fnAddString](8,ISNULL(case when IE.Fecha is not null then FORMAT(IE.Fecha, 'ddMMyyyy') else '' end,''),'0',2) -- Fecha de Movimiento  
  
   + [App].[fnAddString](1,ISNULL(TD.IDTipoDescuento,''),' ',2) -- TIPO DE DESCUENTO(*)  
   + CASE WHEN TD.[Codigo] = '1' THEN  [App].[fnAddString](8,[App].[fnAddString](6,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(4,2)),'.',''),'0',1),'0',2)  
    WHEN TD.[Codigo] = '2' THEN  [App].[fnAddString](8,[App].[fnAddString](7,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(7,2)),'.',''),'0',1),'0',2)  
    ELSE [App].[fnAddString](8,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(7,4)),'.',''),'0',1)END -- VALOR DE DESCUENTO(*)  
  + [App].[fnAddString](1,ISNULL(CASE WHEN IE.AplicaDisminucion = 1 THEN 'S' ELSE 'N' END,''),'',2) -- NUMERO DE CRÉDITO INFONAVIT(*)  
 from RH.tblHistorialInfonavitEmpleado IE  
   inner join rh.tblCatRegPatronal rp  
		on ie.IDRegPatronal = rp.IDRegPatronal  
		and rp.IDRegPatronal = @IDRegPatronal
   INNER join @dtEmpleados E 
		on IE.IDEmpleado = e.IDEmpleado
  left join RH.tblCatInfonavitTipoMovimiento TM  
   on TM.IDTipoMovimiento = IE.IDTipoMovimiento  
  left join RH.tblCatInfonavitTipoDescuento TD  
   on TD.IDTipoDescuento = IE.IDTipoDescuento  
   where IE.Fecha BETWEEN @FechaIni and @Fechafin  
   
     
END
GO
