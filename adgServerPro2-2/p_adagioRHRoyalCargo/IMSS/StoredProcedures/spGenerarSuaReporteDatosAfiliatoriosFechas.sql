USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [IMSS].[spGenerarSuaReporteDatosAfiliatoriosFechas](
	@FechaIni date = '1900-01-01',              
	@Fechafin date = '9999-12-31',              
	@AfectaIDSE bit = 0,
	@FechaIDSE date = '9999-12-31',   
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY,
	@IDUsuario int
)
AS

BEGIN
	
	declare 
		@IDRegPatronal int
		,@dtEmpleados RH.dtEmpleados
	;

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')

	insert into @dtEmpleados      
	exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario   

	select  [App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS
	    -- + [App].[fnAddString](2,ISNULL(' ',''),'',2)
		   + [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL
		   + [App].[fnAddString](5,ISNULL(direc.CodigoPostal,'0'),'0',2) -- Código Postal 
		   + [App].[fnAddString](8,ISNULL(case when e.FechaNacimiento is not null then FORMAT(e.FechaNacimiento, 'ddMMyyyy') else '' end,''),'0',2) -- Fecha de Movimiento
		   + [App].[fnAddString](25,(RTRIM([App].[fnAddString](25,ISNULL(es.NombreEstado,e.EstadoNacimiento) COLLATE Cyrillic_General_CI_AI,' ',2))),' ',1)  -- Lugar de nacimiento
			+ [App].[fnAddString](2, coalesce(ee.Codigo, ''),' ',2) 
			+ [App].[fnAddString](3,ISNULL(e.UMF,''),'0',2) -- UMF
			+ [App].[fnAddString](12,(RTRIM([App].[fnAddString](12,ISNULL(o.Descripcion,''),' ',2))),' ',2) COLLATE Cyrillic_General_CI_AI -- OCUPACION
			+ [App].[fnAddString](1,ISNULL(CASE WHEN e.Sexo = 'MASCULINO' THEN 'M' ELSE 'F'END,' '),'',2) -- SEXO
			+ [App].[fnAddString](1,ISNULL(TS.Codigo,'2'),'',2) -- TIPO DE SALARIO     
			+ [App].[fnAddString](1,0,'0',2) -- HORAS
	from @dtEmpleados e
		join IMSS.tblMovAfiliatorios m on m.IDEmpleado = e.IDEmpleado
        join IMSS.tblCatTipoMovimientos tmov on tmov.IDTipoMovimiento = m.IDTipoMovimiento
		inner join rh.tblCatRegPatronal rp on e.IDRegPatronal = rp.IDRegPatronal
		left join sat.tblCatEstados es on es.IDEstado = e.IDEstadoNacimiento
		left join IMSS.tblCatEstados ee on ee.Nombre = ISNULL(es.NombreEstado,e.EstadoNacimiento)
		left join RH.tblSaludEmpleado se on se.IDEmpleado = e.IDEmpleado
		left join RH.tblCatPuestos p on e.IDPuesto = p.IDPuesto
		left join STPS.tblCatOcupaciones o on o.IDOcupaciones = p.IDOcupacion
        left join rh.tblDireccionEmpleado direc on direc.IDEmpleado = e.IDEmpleado and direc.FechaFin = '9999-12-31' 
		left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = E.IDEmpleado and TTE.[Row] = 1
	left join IMSS.tblCatTipoPension TP on TP.IDTipoPension = TTE.IDTipoPension
	left join IMSS.tblCatTipoSalario TS on TS.IDTipoSalario = TTE.IDTipoSalario
	 where e.IDEmpleado is not null  and m.Fecha between @FechaIni and @Fechafin and tmov.Codigo in ('A', 'R')  

END
GO
