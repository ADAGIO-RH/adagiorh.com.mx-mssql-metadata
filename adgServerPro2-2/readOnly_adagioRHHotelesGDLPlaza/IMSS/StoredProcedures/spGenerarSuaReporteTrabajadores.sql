USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarSuaReporteTrabajadores]    
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
   DECLARE @dtEmpleados RH.dtEmpleados;
   

   insert into @dtEmpleados      
   exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario      
    
    
 select  [App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS    
     -- + [App].[fnAddString](2,ISNULL(' ',''),'',2)    
   + [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL    
  --  + [App].[fnAddString](2,ISNULL(' ',''),'',2)    
   + [App].[fnAddString](13,ISNULL(e.RFC,''),'',2) -- REG. FED. DE CONTRIBUYENTES    
   -- + [App].[fnAddString](2,ISNULL(' ',''),'',2)    
   + [App].[fnAddString](18,ISNULL(e.CURP,''),'',2) -- CURP    
  --  + [App].[fnAddString](2,ISNULL(' ',''),'',2)    
   + [App].[fnAddString](50,  CONVERT(varchar(50), RTRIM(substring(UPPER(COALESCE(E.Paterno,'')+'$'+COALESCE(E.Materno,'')+'$'+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,50 )))COLLATE Cyrillic_General_CI_AI,' ',2) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
   + [App].[fnAddString](1,1,' ',2) -- TIPO DE TRABAJADOR    
   + [App].[fnAddString](1,0,' ',2) -- JORNADA/SEMANA REDUCIDA    
   + [App].[fnAddString](8,ISNULL(FORMAT(e.FechaAntiguedad, 'ddMMyyyy'),''),'0',2) -- FECHA DE ALTA    
   + [App].[fnAddString](7,replace(CAST(ISNULL(e.SalarioIntegrado,0) as decimal(7,2)),'.',''),'0',1) -- SALARIO DIARIO INTEGRADO    
   + [App].[fnAddString](17,ISNULL(e.ClaveEmpleado,''),'',2) -- CLAVE DE UBICACIÓN    
   + [App].[fnAddString](10,ISNULL(IE.NumeroCredito,''),'',2) -- NUMERO DE CRÉDITO INFONAVIT(*)    
   + [App].[fnAddString](8,ISNULL(case when IE.Fecha is not null then FORMAT(IE.Fecha, 'ddMMyyyy') else '' end,''),'0',2) -- FECHA DE INICIO DE DESCUENTO(*)    
   + [App].[fnAddString](1,ISNULL(TD.IDTipoDescuento,''),' ',2) -- TIPO DE DESCUENTO(*)    
   + CASE WHEN TD.[Codigo] = '1' THEN  [App].[fnAddString](8,[App].[fnAddString](6,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(4,2)),'.',''),'0',1),'0',2)    
    WHEN TD.[Codigo] = '2' THEN  [App].[fnAddString](8,[App].[fnAddString](7,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(7,2)),'.',''),'0',1),'0',2)    
    ELSE [App].[fnAddString](8,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(7,4)),'.',''),'0',1)END -- VALOR DE DESCUENTO(*)    
    
 from @dtEmpleados e    
  left join rh.tblCatRegPatronal rp    
   on e.IDRegPatronal = rp.IDRegPatronal    
  left join RH.tblInfonavitEmpleado IE    
   on E.IDEmpleado = IE.IDEmpleado    
  left join RH.tblCatInfonavitTipoMovimiento TM    
   on TM.IDTipoMovimiento = IE.IDTipoMovimiento    
   and TM.Codigo = '15'  
  left join RH.tblCatInfonavitTipoDescuento TD    
   on TD.IDTipoDescuento = IE.IDTipoDescuento    
  where   
    e.IDEmpleado is not null    
 
       
END
GO
