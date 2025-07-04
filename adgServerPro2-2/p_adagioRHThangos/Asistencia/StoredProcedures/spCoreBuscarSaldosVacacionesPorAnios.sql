USE [p_adagioRHThangos]
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
[Asistencia].[spBuscarSaldosVacacionesPorAnios] 1279,1,null,1  
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
2022-09-19				Yesenia Leonel	Se hicieron varias modificaciones por calculos erróneos

NOTA: Si se modifica este sp, por favor de verificar la firma de salida porque este sp se utiliza 
	  en [Asistencia].[spIUVacacionesEmpleados] => [Asistencia].[spBuscarSaldosVacacionesPorAnios]
***************************************************************************************************/  
CREATE proc [Asistencia].[spCoreBuscarSaldosVacacionesPorAnios](  
	@IDEmpleado		int			
	,@Proporcional	bit	 = null
	,@FechaBaja		date = null
	,@IDUsuario		int  = 1
    ,@IDMovimientoBaja int = 0
) as  
BEGIN
  
		SET FMTONLY OFF;  
  
	declare   
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
		,@DifVacaciones int = 0
	;  

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

    IF(@IDMovimientoBaja != 0)
    BEGIN 
        SELECT @FechaAntiguedad = Fecha 
                from IMSS.tblMovAfiliatorios m
                inner join IMSS.tblCatTipoMovimientos tm on m.IDTipoMovimiento = tm.IDTipoMovimiento
                where Fecha = (Select FechaAntiguedad 
                                        from IMSS.tblMovAfiliatorios 
                                        where IDMovAfiliatorio = @IDMovimientoBaja) 
                AND IDEmpleado = @IDEmpleado 
                AND tm.Descripcion in ('ALTA','REINGRESO') 
    END
  
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
  
	select @AniosAntiguedad  = case when @AniosAntiguedad < 1.0 THEN 
																	CASE WHEN @Proporcional = 1 then 1 
																		  else FLOOR(@AniosAntiguedad)  end
									else CASE WHEN @Proporcional = 1 
										      then CEILING(@AniosAntiguedad) 
											  else FLOOR(@AniosAntiguedad)
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

	update anios
		set
			anios.IDTipoPrestacion = pe.IDTipoPrestacion,
			anios.TipoPrestacion = ctp.Descripcion
	from #tempCTE anios
		join RH.tblPrestacionesEmpleado pe on anios.FechaFin between pe.FechaIni and pe.FechaFin
		join RH.tblCatTiposPrestaciones ctp on ctp.IDTipoPrestacion = pe.IDTipoPrestacion
	where pe.IDEmpleado = @IDEmpleado

	SELECT cteAntiguedad.*  
		,isnull(ctpd.DiasVacaciones,0) as Dias
		,0 as DiasTomados       
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,cast('9999-12-31' as date) as FechaIniDisponible
		,cast('9999-12-31' as date)  as FechaFinDisponible
	INTO #tempDiasVacaciones  
	FROM #tempCTE cteAntiguedad  
		left join RH.tblCatTiposPrestacionesDetalle ctpd with (nolock)   
			on ctpd.IDTipoPrestacion = cteAntiguedad.IDTipoPrestacion and cteAntiguedad.Anio = ctpd.Antiguedad  			

	select @MaxAnio = max(Anio)  
    from #tempDiasVacaciones 
	
------------------------------------------------------------------------------------------------------------
/* Se aplica dos veces para corregir algunos que en primer update tienen fechaFinDisponible desactualizada*/

	update t set FechaIniDisponible =  CASE WHEN Anio = 1 then @FechaAntiguedad else (select FechaFinDisponible from #tempDiasVacaciones where anio =(t.anio - 1)) end
		,FechaFinDisponible = Case when Anio = @MaxAnio then '9999-12-31' 
								   else cast( dateadd(day, cast(@VacacionesCaducanEn as int), FechaFin)  as date)
							   end
	from #tempDiasVacaciones t


	update t set FechaIniDisponible = CASE WHEN Anio = 1 then @FechaAntiguedad else(select FechaFinDisponible from #tempDiasVacaciones where anio =(t.anio - 1))  end
		,FechaFinDisponible = Case when Anio = @MaxAnio then '9999-12-31' 
								   else cast( dateadd(day, cast(@VacacionesCaducanEn as int), FechaFin)  as date)
							   end
	from #tempDiasVacaciones t

-------------------------------------------------------------------------------------------------------------------------

	update #tempDiasVacaciones
		set
			DiasTomados = (select count(*) 
							from Asistencia.tblIncidenciaEmpleado 
							where IDIncidencia = 'V' and isnull(Autorizado, 1) = 1
								and Fecha between FechaIniDisponible and FechaFinDisponible
								and IDEmpleado = @IDEmpleado
								-- EXPERIMENTAL
								and (case when @FechaBaja is null then 1
									     when Fecha <= @FechaBaja then 1
										 else 0 end
								) = 1
						)

	select @totalVacaciones = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,'V',@FechaAntiguedad,'9999-12-31')

	while(@counter <= (select max(Anio) from #tempDiasVacaciones))
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = case when @totalVacaciones < DiasTomados THEN Case when @totalVacaciones > Dias then Dias 
																					else @totalVacaciones 
																				end 
									else case when DiasTomados >= Dias then Dias else DiasTomados end
									end
								   
		where Anio = @counter

		set @totalVacaciones = @totalVacaciones - (select DiasTomados from #tempDiasVacaciones where Anio = @counter)
		set @counter = @counter + 1
	END
		
	if(@totalVacaciones > 0)
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = DiasTomados + @totalVacaciones
		where Anio = @MaxAnio
	END

	update #tempDiasVacaciones
		set DiasVencidos = case   
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
				DiasDisponibles = (((DATEDIFF(day, FechaIni, @FechaBaja))/365.4)*Dias)-DiasTomados --getdate())/365.4)*Dias)-DiasTomados		
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
        ,Dias as DiasGenerados  
		,DiasTomados  
		,DiasVencidos  
		,cast(DiasDisponibles as decimal(18,2)) as  DiasDisponibles 
		,TipoPrestacion as TipoPrestacion
        ,ISNULL(FechaIniDisponible, getdate()) as FechaIniDisponible
        ,ISNULL(FechaFinDisponible, getdate()) as FechaFinDisponible
	from #tempDiasVacaciones  
	order by Anio desc
END
GO
