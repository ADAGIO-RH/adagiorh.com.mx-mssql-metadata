USE [p_adagioRHNexus]
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
NO MOVER
2022-10-07			Yesenia Leonel		Se hicieron varios cambios y correcciones revisadas con Paloma Platas de Nexus
***************************************************************************************************/  
  --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=390,@Proporcional=1,@IDUsuario=290
CREATE proc [Asistencia].[spBuscarSaldosVacacionesPorAnios_Nexus_Proporcional_MX] -- 390,0,1
(  
	@IDEmpleado int
	--,@Proporcional bit = 1
	,@Proporcional	bit = 0
	,@FechaBaja date = null
	,@IDUsuario	int = 1
) as  
  
	SET FMTONLY OFF;  
  
	declare   
		 @FechaAntiguedad date  
		,@FechaFin date = getdate()  
		,@IDTipoPrestacion int  
		,@IDCliente int  
		,@AniosAntiguedad float = 0  
		,@VacacionesCaducanEn float = 0  
		,@MaxAnio int = 0  
		,@totalVacaciones int = 0
		,@counter int = 1
		,@AnioEncurso float = 0
		,@OchoMeses float = 0.666
		,@VacacionesRestantes int = 0
		,@FechaValidar int 
	;  

	
   
    

	
  
	if object_id('tempdb..#tempDiasVacaciones') is not null drop table #tempDiasVacaciones;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;  
  
	select   
		@FechaAntiguedad	= 
		case when e.idempleado in (
		 2326
		,2329
		) 
		then  isnull(e.FechaPrimerIngreso,getdate())   else isnull(e.FechaAntiguedad,getdate()) end
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

    
	if(@Idcliente = 7 or (@FechaBaja is not null and @Proporcional = 1)) /*Proporcionales para Dominicana y para todos los finiquitos */
		set @Proporcional = 1
	else
		set @Proporcional = 0

    
    set @FechaBaja = isnull(@FechaBaja, getdate())
	
	
	SELECT @AniosAntiguedad = DATEDIFF(day,@FechaAntiguedad,getdate()) / 365.2425  

	set @AnioEncurso =  @AniosAntiguedad - FLOOR(@AniosAntiguedad) 
	--select @AnioEncurso return
  
	select @AniosAntiguedad  = case when @AniosAntiguedad < 1.0 THEN 
																	CASE WHEN @Proporcional = 1 then 1 
																		  else CASE WHEN @AnioEncurso <= @OchoMeses THEN FLOOR(@AniosAntiguedad)  
																					ELSE CEILING(@AniosAntiguedad) 
																				END
																	end
									else CASE WHEN @Proporcional = 1 
										      then CEILING(@AniosAntiguedad) 
											  else CASE WHEN @AnioEncurso <= @OchoMeses THEN FLOOR(@AniosAntiguedad)  
														ELSE FLOOR(@AniosAntiguedad) 
													END
								          end
								end
	
	if not exists (select top 1 1   
					 from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					 where IDTipoPrestacion = @IDTipoPrestacion 
						and Antiguedad = cast(@AniosAntiguedad as int))  
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

	--select * from #tempCTE

	update anios
		set
			anios.IDTipoPrestacion = pe.IDTipoPrestacion,
			anios.TipoPrestacion = ctp.Descripcion
	from #tempCTE anios
		join RH.tblPrestacionesEmpleado pe on anios.FechaFin between pe.FechaIni and pe.FechaFin
		join RH.tblCatTiposPrestaciones ctp on ctp.IDTipoPrestacion = pe.IDTipoPrestacion
	where pe.IDEmpleado = @IDEmpleado

	--select * from #tempCTE return

	SELECT cteAntiguedad.*  
		--,cast(dateadd(year,1, dateadd(day,-1,FechaIni)) as date) as FechaFin  
		,CAST(isnull(ctpd.DiasVacaciones,0.00) as decimal(18,2)) as Dias
		--,isnull(ctpd.DiasVacaciones,0) as Dias  
		,0 as DiasTomados       
		,cast(0.00 as float) as DiasVencidos  
		,cast(0.00 as float) as DiasDisponibles  
		,cast(null as date) as FechaIniDisponible
		,cast(null as date)  as FechaFinDisponible
	INTO #tempDiasVacaciones  
	FROM #tempCTE cteAntiguedad  
		left join RH.tblCatTiposPrestacionesDetalle ctpd with (nolock)   
			on ctpd.IDTipoPrestacion = cteAntiguedad.IDTipoPrestacion and cteAntiguedad.Anio = ctpd.Antiguedad  			

	select @MaxAnio = max(Anio)  
    from #tempDiasVacaciones 
	


	update t set FechaIniDisponible =  CASE WHEN Anio = 1 then @FechaAntiguedad else (select FechaFinDisponible from #tempDiasVacaciones where anio =(t.anio - 1)) end
		,FechaFinDisponible = Case when Anio = @MaxAnio then '9999-12-31' 
								   else cast( dateadd(day, cast(@VacacionesCaducanEn as int), FechaFin)  as date)
							   end
	from #tempDiasVacaciones t

	--select  @VacacionesCaducanEn

	update t set FechaIniDisponible = CASE WHEN Anio = 1 then @FechaAntiguedad else(select FechaFinDisponible from #tempDiasVacaciones where anio =(t.anio - 1))  end
		,FechaFinDisponible = Case when Anio = @MaxAnio then '9999-12-31' 
								   else cast( dateadd(day, cast(@VacacionesCaducanEn as int), FechaFin)  as date)
							   end
	from #tempDiasVacaciones t


	update #tempDiasVacaciones
		set
			DiasTomados = (select count(*) 
							from Asistencia.tblIncidenciaEmpleado 
							where IDIncidencia = 'V' and isnull(Autorizado, 1) = 1
								and Fecha between FechaIniDisponible and FechaFinDisponible
								and IDEmpleado = @IDEmpleado
						)
	
	--select * from #tempDiasVacaciones return
	select @totalVacaciones = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,'V',@FechaAntiguedad,'9999-12-31')

	while(@counter <= (select max(Anio) from #tempDiasVacaciones))
	BEGIN
		
		select @FechaValidar = year(FechaFin) from #tempDiasVacaciones where anio = @counter

		select @VacacionesRestantes = DiasTomados - Dias from #tempDiasVacaciones where anio = @Counter
		--select @VacacionesRestantes
		if (@VacacionesRestantes > 0)
			update #tempDiasVacaciones set DiasTomados = DiasTomados + @VacacionesRestantes where Anio = (@counter + 1)
		else
			if(@FechaValidar < 2021)
					update #tempDiasVacaciones set DiasTomados = DiasTomados + @VacacionesRestantes where Anio = (@counter + 1)

		set @VacacionesRestantes = 0

		
		

		update #tempDiasVacaciones
				set DiasTomados = case when year(FechaFin) < 2021 then Case when @totalVacaciones >= Dias then Dias --Empiezan a vencer en el año 2021
																			else @totalVacaciones 
																	   end
									   else case when @totalVacaciones < DiasTomados THEN Case when @totalVacaciones > Dias then Dias 
																							else @totalVacaciones 
																					   end 
										          else case when DiasTomados >= Dias then Dias else DiasTomados end
										   end
								   end
			where Anio = @counter

			--if(@counter = 6 and @IDEmpleado = 231)/*Linea agregada porque es el unico colaborador con este caso YL*/
			--	update #tempDiasVacaciones set DiasTomados = 17 where Anio = 6
			
		if( @IDEmpleado = 195)/*Linea agregada porque es el unico colaborador con este caso YL*/
			update #tempDiasVacaciones set DiasVencidos = 7, DiasTomados=17 where Anio = 3
	
		set @totalVacaciones = @totalVacaciones - (select DiasTomados from #tempDiasVacaciones where Anio = @counter)
		set @counter = @counter + 1

		--select * from #tempDiasVacaciones
		

	END
	--return
	--select * from #tempDiasVacaciones return
		

	if(@totalVacaciones > 0)
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = DiasTomados + @totalVacaciones
		where Anio = @MaxAnio
	END

	--select * from #tempDiasVacaciones return

	update #tempDiasVacaciones
		set DiasVencidos = case   
				when (DiasTomados > Dias) then 0   
				when DATEadd(day,@VacacionesCaducanEn,FechaFin) < getdate() then  Dias - DiasTomados else 0 end  
			,DiasDisponibles = case when DATEadd(day,@VacacionesCaducanEn,FechaFin) > getdate() then Dias - DiasTomados else 0 end  

	--select * from #tempDiasVacaciones return

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

  --   select (DATEDIFF(day, FechaIni, @FechaBaja)+1) (((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias)-DiasTomados --getdate())/365.4)*Dias)-DiasTomados		
		--from #tempDiasVacaciones

		--return
	if(@totalVacaciones > 0)
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = DiasTomados + @totalVacaciones
		where Anio = @MaxAnio
	END

	if(@Proporcional = 1)
	BEGIN

		--Para IDcliente 7 (Dominicana) sus dias de vacaciones proporcionales en automatico pasan de 11 a 14
		update v	
			set 
				Dias = CASE WHEN @IDCliente = 7 THEN Case When FLOOR((((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias)) = 12 or FLOOR((((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias)) = 13 THEN 14
														  else FLOOR((((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias))
													 end
							else (((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias) 
					   END
		from #tempDiasVacaciones v
		where Anio = @MaxAnio

		update v	
			set 
				DiasDisponibles = Dias - DiasTomados --getdate())/365.4)*Dias)-DiasTomados		
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
		,CAST(Dias as decimal(18,2)) Dias
        ,CAST(Dias as decimal(18,2)) as DiasGenerados  
		,DiasTomados  
		,DiasVencidos  
		,cast(DiasDisponibles as decimal(18,2)) as  DiasDisponibles 
		,TipoPrestacion as TipoPrestacion
        ,ISNULL(FechaIniDisponible, getdate()) as FechaIniDisponible
        ,ISNULL(FechaFinDisponible, getdate()) as FechaFinDisponible
	from #tempDiasVacaciones  
	order by Anio desc

	/*if object_id('tempdb..#tempDiasVacaciones') is not null drop table #tempDiasVacaciones;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;*/
GO
