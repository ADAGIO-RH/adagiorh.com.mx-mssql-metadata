USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarSuaReporteAltasReingresos]    
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

	select  
		  [App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS    
		+ [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL    
		+ [App].[fnAddString](13,ISNULL(UPPER(e.RFC),''),'',2) -- REG. FED. DE CONTRIBUYENTES    
		+ [App].[fnAddString](18,ISNULL(UPPER(e.CURP),''),'',2) -- CURP    
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](50,  CONVERT(varchar(50), RTRIM(substring(UPPER(COALESCE(E.Paterno,'')+'$'+COALESCE(E.Materno,'')+'$'+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,50 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ','N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
		+ [App].[fnAddString](1,CASE WHEN ISNULL(TTE.IDTipoTrabajador,1) = 1 THEN 2  WHEN ISNULL(TTE.IDTipoTrabajador,1) = 2  THEN 1  else 2 END,' ',2) -- TIPO DE TRABAJADOR    
		+ [App].[fnAddString](1,0,' ',2) -- JORNADA/SEMANA REDUCIDA    
		+ [App].[fnAddString](8,ISNULL(FORMAT(movi.Fecha, 'ddMMyyyy'),''),'0',2) -- FECHA DE ALTA    
		+ [App].[fnAddString](7,replace(CAST(ISNULL(movi.SalarioIntegrado,0) as decimal(7,2)),'.',''),'0',1) -- SALARIO DIARIO INTEGRADO    
		+ [App].[fnAddString](17,ISNULL(e.ClaveEmpleado,''),'',2) -- CLAVE DE UBICACIÓN    
		+ [App].[fnAddString](10,ISNULL(IE.NumeroCredito,''),'',2) -- NUMERO DE CRÉDITO INFONAVIT(*)    
		+ [App].[fnAddString](8,ISNULL(case when IE.Fecha is not null then FORMAT(IE.Fecha, 'ddMMyyyy') else '' end,''),'0',2) -- FECHA DE INICIO DE DESCUENTO(*)    
		+ [App].[fnAddString](1,ISNULL(TD.IDTipoDescuento,''),' ',2) -- TIPO DE DESCUENTO(*)    
		+ CASE WHEN TD.[Codigo] = '1' THEN  [App].[fnAddString](8,[App].[fnAddString](6,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(7,2)),'.',''),'0',1),'0',2)    
		WHEN TD.[Codigo] = '2' THEN  [App].[fnAddString](8,[App].[fnAddString](7,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(7,2)),'.',''),'0',1),'0',2)    
		ELSE [App].[fnAddString](8,replace(CAST(ISNULL(IE.ValorDescuento,0) as decimal(7,2)),'.',''),'0',1)END -- VALOR DE DESCUENTO(*) 
		+[App].[fnAddString](1,CASE WHEN ISNULL(TTE.IDTipoPension,0) = 0 THEN '0' else TP.Codigo END,' ',2) -- TIPO DE TRABAJADOR 
		+[App].[fnAddString](3,SUBSTRING(RP.RegistroPatronal,1,3),' ',2) -- TIPO DE TRABAJADOR 
	from ( 
		select mov.*, ROW_NUMBER()over(partition by mov.IDempleado order by mov.Fecha ASC, tm.Codigo desc) as [Row] 
		from IMSS.tblMovAfiliatorios mov with(nolock)
			inner join IMSS.tblCatTipoMovimientos tm  with(nolock)
				on tm.IDTipoMovimiento = mov.IDTipoMovimiento
		  where mov.Fecha between @FechaIni and @Fechafin
			and tm.Codigo in ('A','R')
			and mov.IDRegPatronal = @IDRegPatronal
	) movi inner join @dtEmpleados e on e.IDEmpleado = movi.IDEmpleado and movi.[Row] = 1
	left join rh.tblCatRegPatronal rp  with(nolock) on movi.IDRegPatronal = rp.IDRegPatronal    
	left join RH.tblInfonavitEmpleado IE with(nolock) on E.IDEmpleado = IE.IDEmpleado    
	left join RH.tblCatInfonavitTipoMovimiento TM  with(nolock) on TM.IDTipoMovimiento = IE.IDTipoMovimiento    
		and TM.Codigo = '15'  
	left join RH.tblCatInfonavitTipoDescuento TD   with(nolock) on TD.IDTipoDescuento = IE.IDTipoDescuento 
	
	left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = E.IDEmpleado and TTE.[Row] = 1
	left join IMSS.tblCatTipoPension TP on TP.IDTipoPension = TTE.IDTipoPension

	where  e.IDEmpleado is not null   

	         

END
GO
