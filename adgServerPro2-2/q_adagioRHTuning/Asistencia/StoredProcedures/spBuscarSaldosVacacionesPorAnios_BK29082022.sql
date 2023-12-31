USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Calcula el historial de saldos de vacaciones de un colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2019-01-01  
** Paremetros  :                
  
 Si se modifica el result set de este sp será necesario modificar los siguientes SP's:  
  [Asistencia].[spBuscarVacacionesPendientesEmpleado]  
  
** DataTypes Relacionados:   [Asistencia].[dtSaldosDeVacaciones]  
  
  select * from RH.tblEmpleadosMaster where claveEmpleado= 'adg0001'
[Asistencia].[spBuscarSaldosVacacionesPorAnios] 1279,1,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2021-11-30				Aneudy Abreu	Se agrega validación para cuando el colaborador tiene más
										de una Prestación
2022-01-01				Aneudy Abreu	Se agregó validación del historial de prestaciones
2022-01-01				Julio Castillo	Se agregó el parámetro de FechaBaja
2022-06-14				Yesenia Leonel	Se modificaron las fechas para traer el proporcional de prestaciones
2022-06-24				Yesenia Leonel	Se modificó de manera personalizada, que algunos clientes si llevan parte proporcional y otrso no
***************************************************************************************************/  
  --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=390,@Proporcional=1,@IDUsuario=290
CREATE proc [Asistencia].[spBuscarSaldosVacacionesPorAnios_BK29082022]-- 390,0,1
(  
		 @IDEmpleado int
		,@Proporcional bit
	  --,@Proporcional	bit = 0
		,@FechaBaja date = null
		,@IDUsuario	int
) as  
	
	set @Proporcional = 0
  
	SET FMTONLY OFF;  
  
	declare   
		--@IDEmpleado int = 19959  
		 @FechaAntiguedad date  
		,@FechaIni date = getdate()  
		,@FechaFin date = getdate()  
		,@IDTipoPrestacion int  
		,@IDCliente int  
		,@AniosAntiguedad float = 0  
		,@VacacionesCaducanEn float = 0  
		,@MaxAnio int = 0  
		,@totalVacaciones int = 0
		,@counter int = 1
	;  

	--set @Proporcional = 0
	set @FechaBaja = isnull(@FechaBaja, getdate())
  
	if object_id('tempdb..#tempDiasVacaciones') is not null drop table #tempDiasVacaciones;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;  
  
	select   
		@FechaAntiguedad	= isnull(e.FechaAntiguedad,getdate())  
		,@IDTipoPrestacion	= pe.IDTipoPrestacion  
		,@IDCliente			= ce.IDCliente  
	from [RH].[tblEmpleadosMaster] e with (nolock)  
		LEFT JOIN [RH].[tblPrestacionesEmpleado] pe with (nolock) ON pe.IDEmpleado = e.IDEmpleado   
			and pe.FechaIni<= @Fechafin and pe.FechaFin >= @Fechafin  
		LEFT JOIN [RH].tblClienteEmpleado ce with (nolock) ON ce.IDEmpleado = e.IDEmpleado   
			and ce.FechaIni<= @Fechafin and ce.FechaFin >= @Fechafin     
	where e.IDEmpleado = @IDEmpleado  
  
   select @totalVacaciones = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,'V',@FechaAntiguedad,'9999-12-31')
  
	if exists (select top 1 1  
				from RH.[TblConfiguracionesCliente] with (nolock)   
				where IDCliente = @IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn')  
	begin  
		select top 1 @VacacionesCaducanEn = cast(isnull(Valor,0.0) as Float)  
		from RH.[TblConfiguracionesCliente] with (nolock)   
		where IDCliente = @IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn'  
	end else   
	begin  
		set @VacacionesCaducanEn = 12775;  
	end;  
      
	SELECT @AniosAntiguedad = DATEDIFF(day,@FechaAntiguedad,getdate()) / 365.2425  
  
	select @AniosAntiguedad  = case when @Proporcional = 0 then FLOOR(@AniosAntiguedad) else @AniosAntiguedad end

	--if not exists (select top 1 1   
	--				 from RH.tblCatTiposPrestacionesDetalle with (nolock)   
	--				 where IDTipoPrestacion = @IDTipoPrestacion 
	--					and Antiguedad = case when @AniosAntiguedad < 1 then 1 else cast(@AniosAntiguedad as int) end)  
	--begin  
	--	exec app.spObtenerError  @IDUsuario= @IDUsuario,@CodigoError='0410002'  
	--	return  
	--end;  
  


	;with cteAntiguedad(Anio, FechaIni) AS
	(
		SELECT cast(1.0 as float),@FechaAntiguedad
		UNION ALL
		SELECT Anio + 1.0,dateadd(year,1,FechaIni)
		FROM cteAntiguedad WHERE Anio < @AniosAntiguedad-- how many times to iterate
	)
	


	 select * 
	 INTO #tempCTE
	 from cteAntiguedad
	 where Anio <= case when @Proporcional = 0 then  FLOOR(@AniosAntiguedad) else CEILING(@AniosAntiguedad) end
   

	IF object_ID('TEMPDB..#TempPrestaciones') IS NOT NULL DROP TABLE #TempPrestaciones

	select cte.FechaIni, pe.IDTipoPrestacion
	into #TempPrestaciones
	from #tempCTE cte
	cross join rh.tblPrestacionesEmpleado pe 
	where  (pe.IDEmpleado = @IDEmpleado)  and DATEADD(year,1,cte.FechaIni) between pe.FechaIni and pe.FechaFin
	--where  (pe.IDEmpleado = @IDEmpleado)  and cte.FechaIni between pe.FechaIni and pe.FechaFin

	SELECT cteAntiguedad.*  
		,dateadd(year,1, dateadd(day,-1,cteAntiguedad.FechaIni)) as FechaFin  
		,isnull(prestaciones.DiasVacaciones,0) as Dias
		--,isnull(ctpd.DiasVacaciones,0) as Dias  
		,0 as DiasTomados       
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
	INTO #tempDiasVacaciones  
	FROM #tempCTE cteAntiguedad 
		inner join #TempPrestaciones temp
			on temp.FechaIni = cteAntiguedad.FechaIni
		left join RH.tblCatTiposPrestacionesDetalle prestaciones 
		on cteAntiguedad.Anio = prestaciones.Antiguedad  
	where prestaciones.IDTipoPrestacion = temp.IDTipoPrestacion

			
		/*left join RH.tblCatTiposPrestacionesDetalle ctpd 
			on ctpd.IDTipoPrestacion = cteAntiguedad.IDTipoPrestacion 
				and ctpd.Antiguedad = cteAntiguedad.Anio*/
								
		--left join (select *  
		--			from RH.tblCatTiposPrestacionesDetalle with (nolock)   
		--			where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad  


	--update temp  set DiasTomados = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,'V',FechaIni,DATEadd(day,@VacacionesCaducanEn,FechaFin))
	--from #tempDiasVacaciones temp

	--select * from #tempDiasVacaciones return

	while(@counter <= (select max(Anio) from #tempDiasVacaciones))
	BEGIN

	update #tempDiasVacaciones
			set DiasTomados = case when @totalVacaciones <= Dias then @totalVacaciones
								   else Dias end
		where Anio = @counter

		set @totalVacaciones = @totalVacaciones - (select DiasTomados from #tempDiasVacaciones where Anio = @counter)

		set @counter = @counter + 1
	END		
	
	--select * from #tempDiasVacaciones return
	
	update #tempDiasVacaciones  
    set DiasVencidos = case   
			when (DiasTomados >= Dias) then 0   
			when DATEadd(day,@VacacionesCaducanEn,FechaFin) < getdate() then  Dias - DiasTomados else 0 end  
		,DiasDisponibles = case when DATEadd(day,@VacacionesCaducanEn,FechaFin) > getdate() then Dias - DiasTomados else 0 end  

	--select * from #tempDiasVacaciones return
  
    select @MaxAnio = max(Anio)  
    from #tempDiasVacaciones  

	if(@totalVacaciones > 0)
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = DiasTomados + @totalVacaciones
		where Anio = @MaxAnio
	END

	--if(@Proporcional = 1)
	--BEGIN
	--	update v	
	--		set Dias = (DATEDIFF(day,FechaIni,@FechaBaja)/365.4)*Dias, /*FechaIni, getdate())/365.4)*Dias,*/
	--			DiasDisponibles = (((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias)-DiasTomados --getdate())/365.4)*Dias)-DiasTomados		
	--	from #tempDiasVacaciones v
	--	where Anio = @MaxAnio
	--END
	--ELSE
	--BEGIN
	--	update v	
	--		set DiasDisponibles = Dias - DiasTomados
	--	from #tempDiasVacaciones v
	--	where Anio = @MaxAnio
	--END

	
	if(@Proporcional = 0 and (@IDCliente =1 or @IDCliente = 5 or @IDCliente =6 or @IDCliente= 7 or @IDCliente = 4 )) /* Solicitud del cliente, Clientes que si son proporcional*/
	BEGIN
		--if()
		--begin
		--print 'Hola'
			update v	
				set DiasDisponibles = Dias - DiasTomados
			from #tempDiasVacaciones v
			where Anio = @MaxAnio
		--end
	END
	ELSE
	BEGIN
		--print 'Adios'
		update v	
			set Dias = (DATEDIFF(day,FechaIni,@FechaBaja)/365.4)*Dias, /*FechaIni, getdate())/365.4)*Dias,*/
				DiasDisponibles = (((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias)-DiasTomados --getdate())/365.4)*Dias)-DiasTomados		
		from #tempDiasVacaciones v
		where Anio = @MaxAnio
	END


	select 
		isnull(Anio,0) as Anio  
		,ISNULL(FechaIni, getdate()) as FechaIni  
		,ISNULL(FechaFin, getdate()) as FechaFin  
		,Dias  
		,DiasTomados  
		,DiasVencidos  
		--,cast(DiasDisponibles as decimal(18,2)) as  DiasDisponibles 
		,cast(DiasDisponibles as decimal(18,2)) as  DiasDisponibles 
		,'' as TipoPrestacion
	from #tempDiasVacaciones  
	order by Anio desc

	/*if object_id('tempdb..#tempDiasVacaciones') is not null drop table #tempDiasVacaciones;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;*/
GO
