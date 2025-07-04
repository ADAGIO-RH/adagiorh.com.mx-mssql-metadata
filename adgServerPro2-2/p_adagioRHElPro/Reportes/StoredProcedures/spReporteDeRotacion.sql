USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Mes	- Plantilla inicial	- Altas	- Bajas -	Plantilla final	- %Rotación -	% de baja
*/

create     proc [Reportes].[spReporteDeRotacion](
	@FechaIni date,
	@FechaFin date,
	@IDUsuario int
) as 
begin	
	SET FMTONLY OFF;  

	declare 
		--@FechaIni date = '2024-08-01',
		--@FechaFin date = '2024-08-30',
		@FechaDiaAntesFechaIni date,
		@IDIdioma varchar(20),
		--@IDUsuario int = 1,
		@empleadosPlantillaInicial [RH].[dtEmpleados],  
		@empleadosVigentesPeriodo [RH].[dtEmpleados]  
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempPlantillaInicial') is not null drop table #tempPlantillaInicial;
	if object_id('tempdb..#tempMovAfilRotacion') is not null drop table #tempMovAfilRotacion;


	set @FechaDiaAntesFechaIni = DATEADD(DAY, -1, @FechaIni)

	insert into @empleadosPlantillaInicial   
	exec [RH].[spBuscarEmpleados] @FechaIni=@FechaDiaAntesFechaIni,@Fechafin=@FechaDiaAntesFechaIni,  @IDUsuario = @IDUsuario


	insert into @empleadosVigentesPeriodo   
	exec [RH].[spBuscarEmpleados] @FechaIni=@FechaIni,@Fechafin=@FechaFin,  @IDUsuario = @IDUsuario

	select  IDDepartamento, IDPuesto, count(IDEmpleado) as Total
	INTO #tempPlantillaInicial
	from @empleadosPlantillaInicial
	group by IDDepartamento, IDPuesto

	if object_id('tempdb..#tempMovAfilRotacion') is not null drop table #tempMovAfilRotacion;

	select mm.IDEmpleado
		,mm.Fecha
		,FechaAlta
		,FechaBaja
		,case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso
		,FechaReingresoAntiguedad
		,mm.IDMovAfiliatorio
		,mmSueldos.SalarioDiario
		,mmSueldos.SalarioVariable
		,mmSueldos.SalarioIntegrado
		,mmSueldos.SalarioDiarioReal
	into #tempMovAfilRotacion
	from (select distinct 
			tm.IDEmpleado,
			tm.Fecha,
			case when(tm.IDEmpleado is not null) then (select  MAX(Fecha) as Fecha
						from IMSS.tblMovAfiliatorios mAlta WITH(NOLOCK)
					join IMSS.tblCatTipoMovimientos c WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento
						where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'
						--Order By mAlta.Fecha Desc , c.Prioridad DESC 
						) end as FechaAlta,
			case when (tm.IDEmpleado is not null) then (select MAX(Fecha) as Fecha
						from IMSS.tblMovAfiliatorios  mBaja WITH(NOLOCK)
					join IMSS.tblCatTipoMovimientos  c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento
						where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'
					and mBaja.Fecha <= FORMAT(@Fechafin,'yyyy-MM-dd')
			--order by mBaja.Fecha desc, C.Prioridad desc
			) end as FechaBaja,
			case when (tm.IDEmpleado is not null) then (select  MAX(Fecha) as Fecha
						from IMSS.tblMovAfiliatorios  mReingreso WITH(NOLOCK)
					join IMSS.tblCatTipoMovimientos   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento
						where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo in('R','A')
					and mReingreso.Fecha <= FORMAT(@Fechafin,'yyyy-MM-dd')
					--and isnull(mReingreso.RespetarAntiguedad,0) <> 1
					--order by mReingreso.Fecha desc, C.Prioridad desc
					) end as FechaReingreso
			,case when (tm.IDEmpleado is not null) then (select MAX(Fecha) as Fecha
						from IMSS.tblMovAfiliatorios  mReingresoAnt WITH(NOLOCK)
					join IMSS.tblCatTipoMovimientos   c  WITH(NOLOCK) on mReingresoAnt.IDTipoMovimiento=c.IDTipoMovimiento
						where mReingresoAnt.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','R')
					and mReingresoAnt.Fecha <= FORMAT(@Fechafin,'yyyy-MM-dd')
					and isnull(mReingresoAnt.RespetarAntiguedad,0) <> 1
					--order by mReingresoAnt.Fecha desc, C.Prioridad desc
					) end as FechaReingresoAntiguedad
			,(Select top 1 mSalario.IDMovAfiliatorio from IMSS.tblMovAfiliatorios  mSalario WITH(NOLOCK)
					join IMSS.tblCatTipoMovimientos   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento
						where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')
						and mSalario.Fecha <= FORMAT(@Fechafin,'yyyy-MM-dd')
						order by mSalario.Fecha desc ) as IDMovAfiliatorio
		from IMSS.tblMovAfiliatorios tm with (nolocK)
		where  tm.IDTipoMovimiento != 4 and tm.Fecha between @FechaIni and @FechaFin
			--inner join #dtEmpleados e on e.IDEmpleado = tm.IDEmpleado
		) mm
			JOIN IMSS.tblMovAfiliatorios mmSueldos with (nolocK) on mm.IDMovAfiliatorio = mmSueldos.IDMovAfiliatorio
	--where ( mm.FechaAlta<=@FechaFin and (mm.FechaBaja>=@FechaIni or mm.FechaBaja is null)) or (mm.FechaReingreso<=@FechaFin)

	--;WITH EmpleadosMes AS (
	--    SELECT 
	--        DATENAME(MONTH, GETDATE()) as Mes,
	--        d.Descripcion as Departamento,
	--        COUNT(e.IDEmpleado) as PlantillaInicial,
	--        SUM(CASE WHEN MONTH(mov.FechaAlta) = MONTH(GETDATE()) 
	--                 AND YEAR(mov.FechaAlta) = YEAR(GETDATE()) THEN 1 ELSE 0 END) as Altas,
	--        SUM(CASE WHEN MONTH(mov.FechaBaja) = MONTH(GETDATE()) 
	--                 AND YEAR(mov.FechaBaja) = YEAR(GETDATE()) THEN 1 ELSE 0 END) as Bajas,
	--        COUNT(e.IDEmpleado) + 
	--            SUM(CASE WHEN MONTH(mov.FechaAlta) = MONTH(GETDATE()) 
	--                     AND YEAR(mov.FechaAlta) = YEAR(GETDATE()) THEN 1 ELSE 0 END) -
	--            SUM(CASE WHEN MONTH(mov.FechaBaja) = MONTH(GETDATE()) 
	--                     AND YEAR(mov.FechaBaja) = YEAR(GETDATE()) THEN 1 ELSE 0 END) as PlantillaFinal
	--    FROM RH.tblEmpleadosMaster e
	--		inner join #tempMovAfilRotacion mov on mov.IDEmpleado = e.IDEmpleado
	--		LEFT JOIN RH.tblCatDepartamentos d ON e.IDDepartamento = d.IDDepartamento
	--   -- WHERE e.Activo = 1
	--    GROUP BY d.Descripcion
	--)


	 --  SELECT 

	 --       d.Descripcion as Departamento,
		--	CASE WHEN (mov.FechaAlta<=@FechaDiaAntesFechaIni and (mov.FechaBaja>=@FechaDiaAntesFechaIni or mov.FechaBaja is null)) or (mov.FechaReingreso<=@FechaDiaAntesFechaIni)
	 --           THEN 1 ELSE 0 END,
	 --      mov.*
	 --   FROM  #tempMovAfilRotacion mov 
	 --       inner join RH.tblEmpleadosMaster e on mov.IDEmpleado = e.IDEmpleado
	 --       LEFT JOIN RH.tblCatDepartamentos d ON e.IDDepartamento = d.IDDepartamento
		--order by d.Descripcion

		--select *
		--from #tempPlantillaInicial

		declare @EmpleadosMes as table (
			Mes varchar(50),
			IDDepartamento int,
			IDPuesto int,
			PlantillaInicial int,
			Altas int,
			Bajas int,
			PlantillaFinal as (PlantillaInicial+Altas)-Bajas
		)

	--;WITH EmpleadosMes AS (

		insert @EmpleadosMes(Mes, IDDepartamento, IDPuesto, PlantillaInicial, Altas, Bajas)
		SELECT 
			FORMAT(ISNULL(mov.Fecha, @FechaIni),'yyyy-MM') as Mes,
			e.IDDepartamento,
			e.IDPuesto,
	  --      SUM(
			--	CASE WHEN (mov.FechaAlta<=@FechaDiaAntesFechaIni and (mov.FechaBaja>=@FechaDiaAntesFechaIni or mov.FechaBaja is null)) or (mov.FechaReingreso<=@FechaDiaAntesFechaIni)
	  --          THEN 1 ELSE 0 END
			--) as PlantillaInicial,
			isnull(plantillaInicial.Total,0) as PlantillaInicial,
			SUM(CASE WHEN mov.FechaAlta between @FechaIni and @FechaFin THEN 1 ELSE 0 END) as Altas,
			SUM(CASE WHEN mov.FechaBaja between @FechaIni and @FechaFin THEN 1 ELSE 0 END) as Bajas
				--,
	   --     --COUNT(e.IDEmpleado) + 
	   --         sum(plantillaInicial.Total)  -
	   --         SUM(CASE WHEN mov.FechaBaja IS NOT NULL 
	   --                  AND MONTH(mov.FechaBaja) = MONTH(mov.FechaAlta) 
	   --                  AND YEAR(mov.FechaBaja) = YEAR(mov.FechaAlta) 
	   --             THEN 1 ELSE 0 END) as PlantillaFinal
		FROM @empleadosVigentesPeriodo e 
			left join #tempMovAfilRotacion mov on mov.IDEmpleado = e.IDEmpleado
		   -- LEFT JOIN RH.tblCatDepartamentos d ON e.IDDepartamento = d.IDDepartamento
			left join #tempPlantillaInicial plantillaInicial on plantillaInicial.IDDepartamento = e.IDDepartamento and plantillaInicial.IDPuesto = e.IDPuesto

		GROUP BY 
			FORMAT(ISNULL(mov.Fecha, @FechaIni),'yyyy-MM'),
			e.IDDepartamento,
			e.IDPuesto,
			plantillaInicial.Total
	--)


	--select *
	--	 --CAST(CASE 
	--  --      WHEN e.PlantillaInicial > 0 
	--  --      THEN (CAST(e.Bajas AS FLOAT) / CAST(e.PlantillaInicial AS FLOAT)) * 100 
	--  --      ELSE 0 
	--  --  END AS DECIMAL(10,2)) as [% Rotación],
	--  --  CAST(CASE 
	--  --      WHEN e.PlantillaFinal > 0 
	--  --      THEN (CAST(e.Bajas AS FLOAT) / CAST(e.PlantillaFinal AS FLOAT)) * 100 
	--  --      ELSE 0 
	--  --  END AS DECIMAL(10,2)) as [% de baja]
	--FROM @EmpleadosMes e
	--	left join RH.tblCatDepartamentos d on d.IDDepartamento = e.IDDepartamento
	--	left join RH.tblCatPuestos p on p.IDPuesto = e.IDPuesto
	--where  e.IDDepartamento = 37	and e.IDPuesto = 86


	SELECT 
		e.Mes,
		e.IDDepartamento,
		e.IDPuesto,
		isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')), 'SIN DEPARTAMENTO') as Departamento,
		isnull(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')), 'SIN PUESTO') as Puesto,
		e.PlantillaInicial,
		e.Altas,
		e.Bajas,
		e.PlantillaFinal,
		CAST(CASE 
			WHEN e.PlantillaInicial > 0 
			THEN (CAST(e.Bajas AS FLOAT) / CAST(e.PlantillaInicial AS FLOAT)) * 100 
			ELSE 0 
		END AS DECIMAL(10,2)) as [% Rotación],
		CAST(CASE 
			WHEN e.PlantillaFinal > 0 
			THEN (CAST(e.Bajas AS FLOAT) / CAST(e.PlantillaFinal AS FLOAT)) * 100 
			ELSE 0 
		END AS DECIMAL(10,2)) as [% de baja]
	FROM @EmpleadosMes e
		left join RH.tblCatDepartamentos d on d.IDDepartamento = e.IDDepartamento
		left join RH.tblCatPuestos p on p.IDPuesto = e.IDPuesto
	ORDER BY 
		isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')), 'SIN DEPARTAMENTO'),
		isnull(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')), 'SIN PUESTO') 
end
GO
