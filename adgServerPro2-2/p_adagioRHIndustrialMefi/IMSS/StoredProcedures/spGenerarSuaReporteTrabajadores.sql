USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarSuaReporteTrabajadores](    
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
    
    
	select  
		[App].[fnAddString](11,ISNULL(UPPER(rp.RegistroPatronal),''),'',2) -- REGISTRO PATRONAL IMSS    
		+ [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL    
		+ [App].[fnAddString](13,ISNULL(UPPER(e.RFC),''),'',2) -- REG. FED. DE CONTRIBUYENTES    
		+ [App].[fnAddString](18,ISNULL(UPPER(e.CURP),''),'',2) -- CURP    
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](50,  CONVERT(varchar(50), RTRIM(substring(UPPER(COALESCE(E.Paterno,'')+'$'+COALESCE(E.Materno,'')+'$'+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,50 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ) , 'Ñ' , 'N' )  -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S)) aqui se le agrego otro replace para la Ñ   
		+ [App].[fnAddString](1,CASE WHEN ISNULL(TTE.IDTipoTrabajador,1) = 1 THEN 2  WHEN ISNULL(TTE.IDTipoTrabajador,1) = 2  THEN 1  else 2 END,'0',2)
		+ [App].[fnAddString](1,0,' ',2) -- JORNADA/SEMANA REDUCIDA    
		+ [App].[fnAddString](8,ISNULL(FORMAT(e.FechaAntiguedad, 'ddMMyyyy'),''),'0',2) -- FECHA DE ALTA    
		+ [App].[fnAddString](7,replace(CAST(ISNULL(e.SalarioIntegrado,0) as decimal(7,2)),'.',''),'0',1) -- SALARIO DIARIO INTEGRADO    
		+ [App].[fnAddString](17,ISNULL(e.ClaveEmpleado,''),'',2) -- CLAVE DE UBICACIÓN    
		+ [App].[fnAddString](10,ISNULL(IE.NumeroCredito,''),'',2) -- NUMERO DE CRÉDITO INFONAVIT(*)    
		+ [App].[fnAddString](8,ISNULL(case when IE.Fecha is not null then FORMAT(IE.Fecha, 'ddMMyyyy') else '' end,''),'0',2) -- FECHA DE INICIO DE DESCUENTO(*)    
		+ [App].[fnAddString](1,ISNULL(TD.IDTipoDescuento,''),' ',2) -- TIPO DE DESCUENTO(*)    
		+ CASE WHEN TD.[Codigo] = '1' THEN  [App].[fnAddString](8,[App].[fnAddString](6,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(4,2)),'.',''),'0',1),'0',2)    
		WHEN TD.[Codigo] = '2' THEN  [App].[fnAddString](8,[App].[fnAddString](7,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(7,2)),'.',''),'0',1),'0',2)    
			ELSE [App].[fnAddString](8,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(8,4)),'.',''),'0',1)END -- VALOR DE DESCUENTO(*)  
		+[App].[fnAddString](1,CASE WHEN ISNULL(TTE.IDTipoPension,0) = 0 THEN '0' else TP.Codigo END,' ',2) -- TIPO DE TRABAJADOR 
		+[App].[fnAddString](3,SUBSTRING(RP.RegistroPatronal,1,3),' ',2) -- TIPO DE TRABAJADOR 
	from @dtEmpleados e    
		left join rh.tblCatRegPatronal rp on e.IDRegPatronal = rp.IDRegPatronal    
		left join RH.tblInfonavitEmpleado IE on E.IDEmpleado = IE.IDEmpleado    
		left join RH.tblCatInfonavitTipoMovimiento TM on TM.IDTipoMovimiento = IE.IDTipoMovimiento    
			and TM.Codigo = '15'  
		left join RH.tblCatInfonavitTipoDescuento TD on TD.IDTipoDescuento = IE.IDTipoDescuento  
		left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = E.IDEmpleado and TTE.[Row] = 1
		left join IMSS.tblCatTipoSalario TS on TS.IDTipoSalario = TTE.IDTipoSalario
		left join IMSS.tblCatTipoPension TP on TP.IDTipoPension = TTE.IDTipoPension
	where e.IDEmpleado is not null    
END
GO
