USE [p_adagioRHIndustrialMefi]
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
[Asistencia].[spCoreBuscarSaldosVacacionesPorAnios] 1279,1,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2021-11-30				Aneudy Abreu	Se agrega validación para cuando el colaborador tiene más
										de una Prestación
2022-01-01				Aneudy Abreu	Se agregó validación del historial de prestaciones
2022-01-01				Julio Castillo	Se agregó el parámetro de FechaBaja
2022-08-04				José Roman		Se crea este Procedimiento como Core del Sistema.
										Se Invoca desde [Asistencia].[spBuscarSaldosVacacionesPorAnios]
***************************************************************************************************/  
  --exec [Asistencia].[spCoreBuscarSaldosVacacionesPorAnios] @IDEmpleado=390,@Proporcional=1,@IDUsuario=290
CREATE   proc [Asistencia].[spCoreBuscarSaldosVacacionesPorAniosBKConfigClientes]-- 390,0,1
(  
	 @IDEmpleado int
	,@Proporcional	bit = null
	,@FechaBaja date = null
	,@IDUsuario	int = 1
) as  
  
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
        ,@DiasDisponibles int = 0
		,@DiasTomados int = 0
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
  
	if exists (select top 1 1  
				from RH.[TblConfiguracionesCliente] with (nolock)   
				where IDCliente = @IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn')  
	begin  
		select top 1 @VacacionesCaducanEn = case when cast(isnull(Valor,0.0) as Float)  = 0 then 12775  else cast(isnull(Valor,0.0) as Float)  end
		from RH.[TblConfiguracionesCliente] with (nolock)   
	where IDCliente = @IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn'  
	end else   
	begin  
		set @VacacionesCaducanEn = 12775;  
	end;  

	IF(@Proporcional is null)
	BEGIN
		if exists (select top 1 1  
					from RH.[TblConfiguracionesCliente] with (nolock)   
					where IDCliente = @IDCliente and IDTipoConfiguracionCliente = 'VacacionesProporcionales')  
		begin  
			select top 1 @Proporcional = case when cast(isnull(Valor,0) as bit)  = 0 then 0  else Cast(isnull(Valor,0) as bit)  end
			from RH.[TblConfiguracionesCliente] with (nolock)   
			where IDCliente = @IDCliente and IDTipoConfiguracionCliente = 'VacacionesProporcionales'  
		end else   
		begin  
			set @Proporcional = 0
		end; 
	END

 
	SELECT @AniosAntiguedad = DATEDIFF(day,@FechaAntiguedad,getdate()) / 365.2425  
  
	select @AniosAntiguedad  = case when @AniosAntiguedad < 1.0 /*and @Proporcional = 1*/ then 1 else @AniosAntiguedad end

	if not exists (select top 1 1   
					 from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					 where IDTipoPrestacion = @IDTipoPrestacion 
						and Antiguedad = case when @AniosAntiguedad < 1 then 1 else cast(@AniosAntiguedad as int) end)  
	begin  
		exec app.spObtenerError  @IDUsuario= @IDUsuario,@CodigoError='0410002'  
		return  
	end;  
  
	;with cteAntiguedad(Anio, FechaIni, IDTipoPrestacion, TipoPrestacion) AS  
    (  
		SELECT cast(1.0 as float), @FechaAntiguedad, 0, cast('' as varchar(50))  
		UNION ALL  
		SELECT Anio + 1.0, dateadd(year,1,FechaIni), 0, cast('' as varchar(50))  
		FROM cteAntiguedad WHERE Anio <= @AniosAntiguedad-- how many times to iterate  
    )  
	
	select *, dateadd(year,1, dateadd(day,-1,FechaIni)) as FechaFin
	INTO #tempCTE  
	from cteAntiguedad  
	where Anio <= case when @Proporcional = 0 then  cast(@AniosAntiguedad as int) else CEILING(@AniosAntiguedad) end

	update anios
		set
			anios.IDTipoPrestacion = pe.IDTipoPrestacion,
			anios.TipoPrestacion = JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))
	from #tempCTE anios
		join RH.tblPrestacionesEmpleado pe on anios.FechaFin between pe.FechaIni and pe.FechaFin
		join RH.tblCatTiposPrestaciones ctp on ctp.IDTipoPrestacion = pe.IDTipoPrestacion
	where pe.IDEmpleado = @IDEmpleado

	SELECT cteAntiguedad.*  
		--,cast(dateadd(year,1, dateadd(day,-1,FechaIni)) as date) as FechaFin  
		,isnull(prestaciones.DiasVacaciones,0) as Dias
		--,isnull(ctpd.DiasVacaciones,0) as Dias  
		,0 as DiasTomados       
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,cast(null as date) as FechaIniDisponible
		,cast(null as date)  as FechaFinDisponible
	INTO #tempDiasVacaciones  
	FROM #tempCTE cteAntiguedad  
		left join (select *  
					from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad  			
		left join RH.tblCatTiposPrestacionesDetalle ctpd 
			on ctpd.IDTipoPrestacion = cteAntiguedad.IDTipoPrestacion 
				and ctpd.Antiguedad = cteAntiguedad.Anio 
		
	update #tempDiasVacaciones
		set 
			FechaIniDisponible = case when isnull(@Proporcional, 1) = 1 then FechaIni else dateadd(YEAR, 1, FechaIni) end
			,FechaFinDisponible = cast( dateadd(day, cast(@VacacionesCaducanEn as int), FechaFin)  as date)

	update #tempDiasVacaciones
		set
			DiasTomados = (select count(*) 
							from Asistencia.tblIncidenciaEmpleado 
							where IDIncidencia = 'V' and isnull(Autorizado, 1) = 1
								and Fecha between FechaIniDisponible and FechaFinDisponible
								and IDEmpleado = @IDEmpleado
						)

	update #tempDiasVacaciones
		set DiasTomados = case when DiasTomados <= Dias then DiasTomados
								else Dias end
			,DiasVencidos = case   
				when (DiasTomados > Dias) then 0   
				when DATEadd(day,@VacacionesCaducanEn,FechaFin) < getdate() then  Dias - DiasTomados else 0 end  
			,DiasDisponibles = case when DATEadd(day,@VacacionesCaducanEn,FechaFin) > getdate() then Dias - DiasTomados else 0 end  
	
	declare 
		@MaxAnioDiasVencidos int = (select MAX(Anio)+1 from #tempDiasVacaciones where DiasDisponibles = 0) 
  
	set @totalVacaciones = (select SUM(DiasTomados) from #tempDiasVacaciones where Anio >= @MaxAnioDiasVencidos)
	
	while(@MaxAnioDiasVencidos <= (select max(Anio) from #tempDiasVacaciones where Anio >= @MaxAnioDiasVencidos))
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = case when @totalVacaciones <= Dias then @totalVacaciones
								   else Dias end
		where Anio = @MaxAnioDiasVencidos

		set @totalVacaciones = @totalVacaciones - (select DiasTomados from #tempDiasVacaciones where Anio = @MaxAnioDiasVencidos)

		set @MaxAnioDiasVencidos = @MaxAnioDiasVencidos + 1
	END		
	
	update #tempDiasVacaciones  
		set DiasDisponibles = case when DATEadd(day,@VacacionesCaducanEn,FechaFin) > getdate() then Dias - DiasTomados else 0 end  

    select @MaxAnio = max(Anio)  
    from #tempDiasVacaciones  

	if(@totalVacaciones > 0)
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = DiasTomados + @totalVacaciones
		where Anio = @MaxAnio
	END

	if(@Proporcional = 1)
	BEGIN
		update v	
			set --Dias = (DATEDIFF(day,FechaIni,@FechaBaja)/365.4)*Dias, /*FechaIni, getdate())/365.4)*Dias,*/
				DiasDisponibles = (((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias)-DiasTomados --getdate())/365.4)*Dias)-DiasTomados		
		from #tempDiasVacaciones v
		where Anio = @MaxAnio
	END
	ELSE
	BEGIN
		update v	
			set DiasDisponibles = Dias - DiasTomados
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
		,TipoPrestacion
	from #tempDiasVacaciones  
	order by Anio desc

	/*if object_id('tempdb..#tempDiasVacaciones') is not null drop table #tempDiasVacaciones;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;*/
GO
